package main

import (
	"errors"
	"testing"
)

func TestServer_Error_MissingDBConn(t *testing.T) {
	_, err := NewServer(ServerConfig{})
	assertEqual(t, errors.New("missing database connection value (PROCESSOR_DB_CONN)"), err)
}

func TestServer_Error_MissingHTTPListen(t *testing.T) {
	_, err := NewServer(ServerConfig{dbConn: "A"})
	assertEqual(t, errors.New("missing http listen value (PROCESSOR_HTTP_LISTEN)"), err)
}
