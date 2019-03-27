package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"go/format"
	"io/ioutil"
	"log"
	"strings"
	"text/template"
)

type Routes struct {
	Routes []Route `json:"routes"`
}

type Route struct {
	Endpoint string   `json:"endpoint"`
	Service  string   `json:"service"`
	Methods  []Method `json:"methods"`
}

type Method struct {
	Method  string `json:"method"`
	Request string `json:"request"`
}

var (
	routesPath = flag.String("routes", "routes.json", "Path to routes definitions file.")
	outputPath = flag.String("output", ".", "Path to output directory.")

	funcs = template.FuncMap{
		"stripPackage": stripPackage,
	}

	handlerTmpl = template.Must(template.New("handler").Funcs(funcs).Parse(`
// Code generated by generator/mount/main.go. DO NOT EDIT.
package mount

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/sessions"

	"github.com/minond/captainslog/server/proto"
	"github.com/minond/captainslog/server/service"
)

var store = sessions.NewCookieStore([]byte(os.Getenv("SESSION_KEY")))

{{range .Routes}}
func Mount{{.Service | stripPackage}}(mux *http.ServeMux, service *{{.Service}}) {
	mux.HandleFunc("{{.Endpoint}}", func(w http.ResponseWriter, r *http.Request) {
		session, err := store.Get(r, "session-name")
		if err != nil {
			http.Error(w, "unable to read request data", http.StatusInternalServerError)
			log.Printf("error getting session: %v", err)
			return
		}

		switch r.Method {
		{{range .Methods}}
		case "{{.Method}}":
			defer r.Body.Close()
			data, err := ioutil.ReadAll(r.Body)
			if err != nil {
				http.Error(w, "unable to read request body", http.StatusBadRequest)
				log.Printf("error reading request body: %v", err)
				return
			}

			req := &{{.Request}}{}
			if err = json.Unmarshal(data, req); err != nil {
				http.Error(w, "unable to decode request", http.StatusBadRequest)
				log.Printf("error unmarshaling request: %v", err)
				return
			}

			ctx := context.Background()
			for key, val := range session.Values {
				ctx = context.WithValue(ctx, key, val)
			}

			res, err := service.Create(ctx, req)
			if err != nil {
				http.Error(w, "unable to handle request", http.StatusInternalServerError)
				log.Printf("error handling request: %v", err)
				return
			}

			out, err := json.Marshal(res)
			if err != nil {
				http.Error(w, "unable to encode response", http.StatusInternalServerError)
				log.Printf("error marshaling response: %v", err)
				return
			}

			w.Write(out)
		{{end}}

		default:
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	})
}
{{end}}
`))
)

func init() {
	flag.Parse()
}

func main() {
	data, err := ioutil.ReadFile(*routesPath)
	if err != nil {
		log.Fatalf("error reading routes file: %v", err)
	}

	routes := &Routes{}
	json.Unmarshal(data, routes)

	buff := &bytes.Buffer{}
	if err = handlerTmpl.Execute(buff, routes); err != nil {
		log.Fatalf("error generating template: %v", err)
	}

	unformatted := buff.Bytes()
	contents, err := format.Source(unformatted)
	if err != nil {
		log.Fatalf("error formatting contents: %v", err)
	}

	if err = ioutil.WriteFile(*outputPath, contents, 0644); err != nil {
		log.Fatalf("error writing to file: %v", err)
	}
	log.Printf("wrote %d bytes to %s", len(contents), *outputPath)
}

func stripPackage(input string) string {
	parts := strings.SplitN(input, ".", 2)
	return parts[1]
}
