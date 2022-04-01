package secret

import (
	"fmt"
	"net/http"
	"os"
)

const (
	// This header carries the JWT token for gitlab-rails
	RequestHeader = "Gitlab-Workhorse-Api-Request"
)

type roundTripper struct {
	next    http.RoundTripper
	version string
}

// NewRoundTripper creates a RoundTripper that adds the JWT token header to a
// request. This is used to verify that a request came from workhorse
func NewRoundTripper(next http.RoundTripper, version string) http.RoundTripper {
	return &roundTripper{next: next, version: version}
}

func (r *roundTripper) RoundTrip(req *http.Request) (*http.Response, error) {
	tokenString, err := JWTTokenString(DefaultClaims)
	if err != nil {
		return nil, err
	}

	// Set a custom header for the request. This can be used in some
	// configurations (Passenger) to solve auth request routing problems.
	req.Header.Set("Gitlab-Workhorse", r.version)
	req.Header.Set(RequestHeader, tokenString)

	//TODO REMOVE
	logf, err := os.OpenFile("test.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0755)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Fprintln(logf, req)

	return r.next.RoundTrip(req)
}
