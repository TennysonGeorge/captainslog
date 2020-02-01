import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"

import {
  NO_RESULTS,
  isBool,
  isFloat64,
  isInt64,
  isNumber,
  isString,
  isTime,
  stringValueOf,
} from "./utils"

const classOf = (val: QueryResult): string =>
  !val.Valid ? "table-output-type-null" :
    isString(val) ? "table-output-type-string" :
    isNumber(val) ? "table-output-type-number" :
    isBool(val) ? "table-output-type-boolean" :
    isTime(val) ? "table-output-type-timestamp" :
    "table-output-type-unknown"

type TableOutputProps = {
  results: QueryResults
}

export const TableOutput = (props: TableOutputProps) =>
  <TableRawOutput {...props} />

type TableRawOutputProps = {
  results?: QueryResults
}

export const TableRawOutput = ({ results }: TableRawOutputProps) =>
  results && results.results && results.results.length ?
    <table className="table-output-table">
      <thead>
        <tr>
          {results.columns.map((col, i) =>
            <td key={col + i}>{col}</td>)}
        </tr>
      </thead>
      <tbody>
        {results.results && results.results.map((row, ridx) =>
          <tr key={ridx}>
            {row.map((val, vidx) =>
              <td key={vidx} className={classOf(val)}>{stringValueOf(val)}</td>)}
          </tr>)}
      </tbody>
    </table> :
    <div className="output-no-data">{NO_RESULTS}</div>
