package upload

/*
import (
	"context"
	"io"
	"os"
	"path/filepath"

	"github.com/pkg/errors"
	"gitlab.com/gitlab-org/gitaly/v14/client"
	"gitlab.com/gitlab-org/gitaly/v14/proto/go/gitalypb"
	"google.golang.org/grpc"
)

type DirUploader struct {
	baseDir string
	conn    *grpc.ClientConn
	client  gitalypb.OperationServiceClient
}

func NewDirUploader(baseDir, addr string) (*DirUploader, error) {
	conn, err := client.Dial(addr, nil)
	if err != nil {
		return nil, errors.Wrap(err, "grpc dial failed")
	}
	client := gitalypb.NewOperationServiceClient(conn)
	return &DirUploader{
		baseDir: baseDir,
		conn:    conn,
		client:  client,
	}, nil
}

func (ul *DirUploader) UploadDir(dirName, branchName, commitMessage string, repository *gitalypb.Repository, user *gitalypb.User) error {
	stream, err := ul.client.UserCommitFiles(context.Background())
	if err != nil {
		return errors.Wrap(err, "create user commit files stream failed")
	}

	if err := stream.Send(headerRequest(repository, user, branchName, []byte(commitMessage), "")); err != nil {
		return errors.Wrap(err, "send header request failed")
	}

	if err := stream.Send(createDirHeaderRequest(dirName)); err != nil {
		return errors.Wrap(err, "create dir header request failed")
	}

	// dirName 需要加上 前缀
	tmpDir := filepath.Join(ul.baseDir, dirName)
	entries, err := os.ReadDir(tmpDir)
	if err != nil {
		return errors.Wrapf(err, "read dir %s failed", dirName)
	}

	for _, entry := range entries {
		if entry.Name() == "." || entry.Name() == ".." || entry.Name() == ".gitkeep" {
			continue
		}

		fileName := filepath.Join(dirName, entry.Name())
		if err := ul.sendFile(stream, fileName); err != nil {
			return err
		}
	}

	_, err = stream.CloseAndRecv()
	if err != nil {
		return errors.Wrapf(err, "close upload dir stream failed")
	}
	return nil
}

func (ul *DirUploader) sendFile(stream gitalypb.OperationService_UserCommitFilesClient, name string) error {
	fullFileName := filepath.Join(ul.baseDir, name)
	file, err := os.OpenFile(fullFileName, os.O_RDONLY, 0000)
	if err != nil {
		return errors.Wrapf(err, "open file %s failed", name)
	}

	if err := stream.Send(createFileHeaderRequest(name)); err != nil {
		return errors.Wrapf(err, "send file %s header request failed", name)
	}

	data := make([]byte, 2048)
	for {
		n, err := file.Read(data)
		if err != nil {
			if err == io.EOF {
				return nil
			}
			return errors.Wrapf(err, "read file %s failed", name)
		}

		if err := stream.Send(actionContentRequest(data[:n])); err != nil {
			return errors.Wrapf(err, "send file %s content failed", name)
		}
	}
}

func (ul *DirUploader) Close() error {
	return ul.conn.Close()
}
*/ //
