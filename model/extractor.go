package model

import (
	"gopkg.in/src-d/go-kallax.v1"
)

// DataType represents the data type of extracted data.
type DataType int32

const (
	StringData DataType = iota
	NumberData

	// BooleanData identifies the existence of extracted data. When the
	// extractor does not match, no data is saved. When the extractor matches,
	// the data will be labeled as "true".
	BooleanData
)

type Extractor struct {
	kallax.Model `table:"extractors" pk:"guid"`

	GUID     kallax.ULID `json:"guid"`
	BookGUID kallax.ULID
	Label    string
	Match    string
	Type     DataType
}

func newExtractor(label, match string, typ DataType, book *Book) (*Extractor, error) {
	extractor := &Extractor{
		GUID:  kallax.NewULID(),
		Label: label,
		Match: match,
		Type:  typ,
	}

	if book != nil {
		extractor.BookGUID = book.GUID
	}

	return extractor, nil
}
