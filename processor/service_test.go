package main

import (
	"context"
	"errors"
	"testing"
)

func TestService_Error_MissingText(t *testing.T) {
	service := NewService(nil)
	req := &ProcessingRequest{}
	_, err := service.Handle(context.TODO(), req)
	assertEqual(t, ErrReqMissingText, err)
}

func TestService_Error_MissingBookID(t *testing.T) {
	service := NewService(nil)
	req := &ProcessingRequest{Text: "hi"}
	_, err := service.Handle(context.TODO(), req)
	assertEqual(t, ErrReqMissingBookID, err)
}

func TestService_Error_ExtractorLookup(t *testing.T) {
	repo := &testRepository{extractorLookupError: errors.New("bad")}
	req := &ProcessingRequest{Text: "hi", BookID: 2}
	service := NewService(repo)
	_, err := service.Handle(context.TODO(), req)
	assertEqual(t, ErrUnableToFetchExtractors, err)
}

func TestService_Error_ShorhandLookup(t *testing.T) {
	repo := &testRepository{shorthandLookupError: errors.New("bad")}
	req := &ProcessingRequest{Text: "hi", BookID: 2}
	service := NewService(repo)
	_, err := service.Handle(context.TODO(), req)
	assertEqual(t, ErrUnableToFetchShorthands, err)
}

func TestService_HappyPath_ServeHTTP(t *testing.T) {
	repo := &testRepository{}
	req := &ProcessingRequest{Text: "hi", BookID: 2}
	service := NewService(repo)
	res, err := service.Handle(context.TODO(), req)
	assertEqual(t, nil, err)
	assertEqual(t, &ProcessingResponse{Text: "hi", Data: make(map[string]interface{})}, res)
}
