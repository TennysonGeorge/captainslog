import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"

import { ChartOutput } from "./chart"
import { TableOutput } from "./table"
import { ValueOutput } from "./value"

export enum OutputType {
  InvalidOutput,
  TableOutput,
  ChartOutput,
  ValueOutput,
}

type OutputProps = {
  type: OutputType
  results: QueryResults
}

export const Output = (props: OutputProps) => {
  switch (props.type) {
    case OutputType.TableOutput:
      return <TableOutput results={props.results} />

    case OutputType.ChartOutput:
      return <ChartOutput results={props.results} />

    case OutputType.ValueOutput:
      return <ValueOutput results={props.results} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
