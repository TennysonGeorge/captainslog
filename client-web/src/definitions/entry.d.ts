export type Entry = {
  guid: string
  text: string
  createdAt: string
  updatedAt: string
  data?: Map<string, string>
}

export type EntryCreateRequest = {
  guid: string
  text: string
  createdAt: string
  bookGuid: string
}

export type EntryCreateResponse = {
  guid: string
  entry: Entry
}
