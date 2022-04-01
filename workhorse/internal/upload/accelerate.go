package upload

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
_	"net/http/httputil"
	"os"
	"path/filepath"
	"strings"

	"github.com/dgrijalva/jwt-go"
_	 "gitlab.com/gitlab-org/labkit/log"

	"gitlab.com/gitlab-org/gitaly/v14/proto/go/gitalypb"
	"gitlab.com/gitlab-org/gitlab/workhorse/internal/api"
	"gitlab.com/gitlab-org/gitlab/workhorse/internal/gitaly"
	"gitlab.com/gitlab-org/gitlab/workhorse/internal/helper"
)

const RewrittenFieldsHeader = "Gitlab-Workhorse-Multipart-Fields"

type MultipartClaims struct {
	RewrittenFields map[string]string `json:"rewritten_fields"`
	jwt.StandardClaims
}
type JsonResult struct {
	FilePath string
	Message  string
}

type FormValue map[string]string

func Accelerate(rails PreAuthorizer, h http.Handler, p Preparer) http.Handler {
	return rails.PreAuthorizeHandler(func(w http.ResponseWriter, r *http.Request, a *api.Response) {
		s := &SavedFileTracker{Request: r}

		opts, _, err := p.Prepare(a)
		if err != nil {
			helper.Fail500(w, r, fmt.Errorf("Accelerate: error preparing file storage options"))
			return
		}

		HandleFileUploads(w, r, h, a, s, opts)
	}, "/authorize")
}

// 新建目录并提交
func DirUploadCommit(rails *api.API, publicPath string) http.Handler {
	return rails.PreAuthorizeHandler(func(w http.ResponseWriter, r *http.Request, a *api.Response) {
		files, formvalue, err := HandleDirUploads(r, publicPath, a)
		if err != nil {
			http.Error(w, fmt.Sprint(err), http.StatusInternalServerError)
			return
		}
		fmt.Println(a)
		err = CommitDir(r.Context(), a, files, formvalue)
		if err != nil {
			http.Error(w, fmt.Sprint(err), http.StatusInternalServerError)
			return
		}

		w.Header().Set("content-type", "text/json")
		w.WriteHeader(http.StatusOK)
		msg, err := json.Marshal(JsonResult{Message: "success", FilePath: strings.TrimLeft(a.Path, "main/")})
		w.Write(msg)
		for _, v := range files {
			os.Remove(v.LocalPath)
		}
		return
	}, "")
}

func HandleDirUploads(r *http.Request, publicPath string, a *api.Response) ([]*gitaly.UploadFiles, FormValue, error) {

	//dump, err := httputil.DumpRequest(r, true)
	//fmt.Printf("%s, %q", err, dump)
	//fmt.Println(r.PostFormValue("branch_name"))
	//fmt.Println(r.PostFormValue("commit_message"))
	
	reader, err := r.MultipartReader()
	tmpPath := publicPath + "/" + os.TempDir() + "/"
	files := []*gitaly.UploadFiles{}
	formvalue := make(map[string]string)
	if err != nil {
		return files, formvalue, fmt.Errorf("test HandleDirUploads : %v", err)
	}

	for {
		p, err := reader.NextPart()
		if err != nil {
			if err == io.EOF {
				break
			}
			return files, formvalue, fmt.Errorf("HandleDirUploads : %v", err)
		}

		name := p.FormName()
		if name == "" {
			continue
		}
		if name == "branch_name" || name == "commit_message" {
			buf := new(bytes.Buffer)
			buf.ReadFrom(p)
			//log.Println(" %s: %s", name, buf.String())
			formvalue[name] = buf.String()
		}
		if p.FileName() != "" {
			postfilename := p.Header.Get("Content-Disposition")
			postfilenameArr := strings.Split(postfilename,";") 	
			postfilename = strings.Split(postfilenameArr[2],"=")[1]
			postfilename = strings.Trim(postfilename,"\"")
			relpath := filepath.Dir(postfilename)
			fmt.Printf("%v, relPath: %+v , FIleName: %v\n", tmpPath, relpath,postfilename)
			inputReader := ioutil.NopCloser(p)
			defer inputReader.Close()
			if _, err := os.Stat(relpath); os.IsNotExist(err) {
				if err = os.MkdirAll(tmpPath+relpath, os.ModePerm); err != nil {
					return files, formvalue, fmt.Errorf("HandleDirUploads : %v", err)
				}
			}
			f, err := os.OpenFile(tmpPath+postfilename, os.O_WRONLY|os.O_CREATE, 0666)
			if err != nil {
				return files, formvalue, fmt.Errorf("HandleDirUploads : %v", err)
			}
			defer f.Close()
			io.Copy(f, inputReader)
			files = append(files, &gitaly.UploadFiles{LocalPath: tmpPath + postfilename, CommitPath: strings.TrimLeft(a.Path, "main/") + "/" + postfilename})
		}
	}
	return files, formvalue, nil
}
func CommitDir(ctx context.Context, a *api.Response, files []*gitaly.UploadFiles, formvalue FormValue) error {
	ctx, operation, err := gitaly.NewOperationServiceClient(ctx, a.GitalyServer)
	if err != nil {
		return fmt.Errorf("operation.NewOperationServiceClient: %v", err)
	}
	user := &gitalypb.User{
		Name:       []byte(a.User.Name),
		Email:      []byte(a.User.Email),
		GlId:       a.User.GlId,
		GlUsername: a.User.GlUsername,
		//Timezone:   a.User.Timezone,
	}

	if err := operation.UserCommitFiles(ctx, user, &a.Repository, formvalue["branch_name"], []byte(formvalue["commit_message"]), files); err != nil {
		return fmt.Errorf("operation.UserCommitFiles:%v", err)
	}

	return nil
}
