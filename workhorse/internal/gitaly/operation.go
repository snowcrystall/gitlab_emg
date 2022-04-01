package gitaly

import (
	"context"
	"strings"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"gitlab.com/gitlab-org/gitaly/v14/proto/go/gitalypb"
)

type OperationServiceClient struct {
	cc gitalypb.OperationServiceClient
}
type UploadFiles struct {
//	IsDir      bool
	LocalPath  string
	CommitPath string
}

func (client *OperationServiceClient) UserCommitFiles(ctx context.Context, user *gitalypb.User, repo *gitalypb.Repository, branchName string, CommitMessage []byte, files []*UploadFiles) error {
	stream, err := client.cc.UserCommitFiles(ctx)
	if err != nil {
		return fmt.Errorf("create user commit files stream failed : %v", err)
	}
	reqs := []*gitalypb.UserCommitFilesRequest{
		headerRequest(repo, user, branchName, CommitMessage, ""),
		createDirHeaderRequest(strings.SplitAfter(files[0].CommitPath,"/")[1]),
	}
	for _, req := range reqs {
		if err := stream.Send(req); err != nil {
			return fmt.Errorf("send request failed : %v", err)
		}
	}

	for _, v := range files {
		if filepath.Base(v.LocalPath) == "." || filepath.Base(v.LocalPath) == ".." || filepath.Base(v.LocalPath) == ".gitkeep" {
			continue
		}

		if err := sendFile(stream, v.LocalPath, v.CommitPath); err != nil {
			return err
		}
	}
	_, err = stream.CloseAndRecv()
	if err != nil {
		return fmt.Errorf("close request sending : %v", err)
	}
	return nil
}

func sendFile(stream gitalypb.OperationService_UserCommitFilesClient, localpath string, commitpath string) error {
	file, err := os.OpenFile(localpath, os.O_RDONLY, 0000)
	if err != nil {
		return fmt.Errorf("open file %s failed", localpath)
	}

	fmt.Printf("createFileHeaderRequest : %s\n", commitpath)
	if err := stream.Send(createFileHeaderRequest(commitpath)); err != nil {
		return fmt.Errorf("send file %s header request failed", commitpath)
	}

	data := make([]byte, 2048)
	for {
		n, err := file.Read(data)
		if err != nil {
			if err == io.EOF {
				return nil
			}
			return fmt.Errorf("read file %s failed", localpath)
		}

		if err := stream.Send(actionContentRequest(data[:n])); err != nil {
			return fmt.Errorf("send file %s content failed", localpath)
		}
	}
}

func headerRequest(repo *gitalypb.Repository, user *gitalypb.User, branchName string, commitMessage []byte, startBranchName string) *gitalypb.UserCommitFilesRequest {
	return &gitalypb.UserCommitFilesRequest{
		UserCommitFilesRequestPayload: &gitalypb.UserCommitFilesRequest_Header{
			Header: &gitalypb.UserCommitFilesRequestHeader{
				Repository:      repo,
				User:            user,
				BranchName:      []byte(branchName),
				CommitMessage:   commitMessage,
				StartBranchName: []byte(startBranchName),
				StartRepository: nil,
			},
		},
	}
}

func createDirHeaderRequest(filePath string) *gitalypb.UserCommitFilesRequest {
	fmt.Printf("createDirHeaderRequest : %s\n", filePath)
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:   gitalypb.UserCommitFilesActionHeader_CREATE_DIR,
				FilePath: []byte(filePath),
			},
		},
	})
}

func createFileHeaderRequest(filePath string) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:        gitalypb.UserCommitFilesActionHeader_CREATE,
				Base64Content: false,
				FilePath:      []byte(filePath),
			},
		},
	})
}

func createBase64FileHeaderRequest(filePath string) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:        gitalypb.UserCommitFilesActionHeader_CREATE,
				Base64Content: true,
				FilePath:      []byte(filePath),
			},
		},
	})
}

func updateFileHeaderRequest(filePath string) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:   gitalypb.UserCommitFilesActionHeader_UPDATE,
				FilePath: []byte(filePath),
			},
		},
	})
}

func updateBase64FileHeaderRequest(filePath string) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:        gitalypb.UserCommitFilesActionHeader_UPDATE,
				FilePath:      []byte(filePath),
				Base64Content: true,
			},
		},
	})
}

func chmodFileHeaderRequest(filePath string, executeFilemode bool) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:          gitalypb.UserCommitFilesActionHeader_CHMOD,
				FilePath:        []byte(filePath),
				ExecuteFilemode: executeFilemode,
			},
		},
	})
}

func moveFileHeaderRequest(previousPath, filePath string, infer bool) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:       gitalypb.UserCommitFilesActionHeader_MOVE,
				FilePath:     []byte(filePath),
				PreviousPath: []byte(previousPath),
				InferContent: infer,
			},
		},
	})
}

func deleteFileHeaderRequest(filePath string) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Header{
			Header: &gitalypb.UserCommitFilesActionHeader{
				Action:   gitalypb.UserCommitFilesActionHeader_DELETE,
				FilePath: []byte(filePath),
			},
		},
	})
}

func actionContentRequest(content []byte) *gitalypb.UserCommitFilesRequest {
	return actionRequest(&gitalypb.UserCommitFilesAction{
		UserCommitFilesActionPayload: &gitalypb.UserCommitFilesAction_Content{
			Content: content,
		},
	})
}

func actionRequest(action *gitalypb.UserCommitFilesAction) *gitalypb.UserCommitFilesRequest {
	return &gitalypb.UserCommitFilesRequest{
		UserCommitFilesRequestPayload: &gitalypb.UserCommitFilesRequest_Action{
			Action: action,
		},
	}
}
