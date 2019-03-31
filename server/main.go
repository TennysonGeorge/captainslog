//go:generate kallax gen --input model
//go:generate go run generator/mount/main.go -routes service/mount/routes.json -output service/mount/autogen.go
package main

import (
	"database/sql"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"

	"github.com/minond/captainslog/server/service"
	"github.com/minond/captainslog/server/service/mount"
)

func main() {
	log.Print("[INFO] initializing server")
	db, err := sql.Open(os.Getenv("DATABASE_DRIVER"), os.Getenv("DATABASE_CONN"))
	if err != nil {
		log.Fatalf("[ERROR] error opening database connection: %v", err)
	}
	defer db.Close()

	router := mux.NewRouter()

	bookService := service.NewBookService(db)
	entryService := service.NewEntryService(db)
	extractorService := service.NewExtractorService(db)

	// TODO add real sessions with real auth
	store := sessions.NewCookieStore([]byte(os.Getenv("SESSION_KEY")))
	router.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			session, _ := store.Get(r, "main")
			session.Values["userguid"] = "e26e269c-0587-4094-bf01-108c61b0fa8a"
			session.Save(r, w)
			next.ServeHTTP(w, r)
		})
	})

	mount.MountBookService(router, bookService)
	mount.MountEntryService(router, entryService)
	mount.MountExtractorService(router, extractorService)

	http.Handle("/", router)

	listen := os.Getenv("LISTEN")
	log.Printf("[INFO] listening on `%s`", listen)
	log.Fatal(http.ListenAndServe(listen, nil))
}
