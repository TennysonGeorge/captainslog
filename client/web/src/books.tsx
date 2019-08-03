import * as React from "react"
import { useState, useEffect } from "react"
import { Link } from "react-router-dom"

import { Book } from "./definitions"
import { cachedGetBooks } from "./remote"

export const BookListView = (props: {}) => {
  const [books, setBooks] = useState<Book[]>([])

  useEffect(() => {
    cachedGetBooks().then(setBooks)
  }, [])

  const links = books.map((book) =>
    <Link key={book.guid} to={`/${book.guid}`}>
      <div>{book.name}</div>
    </Link>)

  return <div>{links}</div>
}
