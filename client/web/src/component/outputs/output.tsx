import * as React from "react"

import { OutputType, QueryResult, QueryResults } from "../../definitions"

import { ChartOutput } from "./chart"
import { TableOutput } from "./table"
import { ValueOutput } from "./value"

export type Definition = {
  type: OutputType
  label: string
  query: string
}

type LookupOutputProps = {
  definition: Definition
  results: QueryResults
  onEdit?: (def: Definition) => void
}

export const LookupOutput = (props: LookupOutputProps) => {
  switch (props.definition.type) {
    case OutputType.TableOutput:
      return <TableOutput {...props} />

    case OutputType.ChartOutput:
      return <ChartOutput {...props} />

    case OutputType.ValueOutput:
      return <ValueOutput {...props} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}

type HeaderProps = {
  definition: Definition
  onEdit?: (def: Definition) => void
}

export const Header = ({ definition, onEdit }: HeaderProps) =>
  <div className="output-header">
    <div className="output-label" title={definition.query}>
      {definition.label}
    </div>
    {onEdit ?
      <div className="output-edit" onClick={() => onEdit(definition)}>
        [edit]
      </div> :
      null}
  </div>
