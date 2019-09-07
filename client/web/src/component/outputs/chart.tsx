import * as React from "react"

import {
  Line,
  LineChart,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';

import { QueryResults } from "../../definitions"
import { Definition, Header } from "./output"

import { NO_RESULTS, flattenResultsHash } from "./utils"

type ChartOutputProps = {
  definition: Definition
  results: QueryResults
  onEdit?: (def: Definition) => void
}

export const ChartOutput = (props: ChartOutputProps) =>
  <ChartRawOutput {...props} />

type ChartRawOutputProps = {
  definition: Definition
  results?: QueryResults
  onEdit?: (def: Definition) => void
}

export const ChartRawOutput = ({ definition, results, onEdit }: ChartRawOutputProps) =>
  <div className="output chart-output">
    <Header definition={definition} onEdit={onEdit} />
    {results && results.data && results.data.length ?
      <div className="chart-output-wrapper">
        <LineChart
          data={flattenResultsHash(results)}
          width={680}
          height={200}
          margin={{ top: 0, right: 0, bottom: 0, left: 0 }}
        >
          <Tooltip />
          <XAxis dataKey="x" />
          <YAxis dataKey="y" width={40} />
          <Line type="monotone" dataKey="y" stroke="#82ca9d" isAnimationActive={false} />
        </LineChart>
      </div> :
      <div className="output-no-data">{NO_RESULTS}</div>}
  </div>
