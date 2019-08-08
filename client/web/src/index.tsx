import * as React from "react"
import * as ReactDOM from "react-dom"
import { Router, Route, Switch } from "react-router-dom"

import { Books } from "./books"
import { Entries } from "./entries"
import { Query } from "./query"

import history from "./history"

require("./index.css")

export const Index = () => (
  <div>
    <Router history={history}>
      <Switch>
        <Route exact={true} path="/" component={Books} />
        <Route exact={true} path="/query" component={Query} />
        <Route exact={true} path="/:guid/:at?" render={(prop) => {
          let guid = prop.match.params["guid"]
          let at = prop.match.params["at"] || Date.now()
          let date = new Date(+at)
          return <>
            <Books />
            <Entries bookGuid={guid} date={date} />
          </>
        }} />
      </Switch>
    </Router>
  </div>
)

ReactDOM.render(<Index />, document.getElementById("body"))
