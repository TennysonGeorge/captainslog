require "net/http"
require "uri"

module Querier
  Error = Class.new(ExternalService::Error)

  # RequestError represents an error that occured _while making_ the request to
  # the querier service.
  RequestError = Class.new(Error)

  # QueryingError represents an error _from_ the querier service. This means
  # the request was successful, but there was an error while processing or
  # executing the query.
  QueryingError = Class.new(Error)

  Client = ExternalService.client(Querier::Response,
                                  Querier::RequestError,
                                  Rails.application.config.querier)
end
