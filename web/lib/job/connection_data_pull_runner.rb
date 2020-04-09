class Job::ConnectionDataPullRunner < Job::Runner
  prepend SimpleCommand
  include Instrumented

  traced :call, :create_or_update_entries, :update_connection_credentials

  def call
    print_job_information
    create_or_update_entries
    update_connection_credentials if oauth_client?
    log.puts "done"
  end

private

  def print_job_information
    log.puts "pulling data for connection id #{connection.id}"
    log.puts "adding entries to book id #{book.id}"
  end

  def create_or_update_entries
    proto_entries do |proto_entry|
      log.write "handling entry with digest #{proto_entry.digest.strip} ... "
      create_entry(proto_entry)
    rescue ActiveRecord::RecordInvalid
      update_entry(proto_entry)
    end
  end

  def update_connection_credentials
    log.puts "updating connection credentials"
    UpdateConnectionCredentials.call(connection)
  end

  # @param [ProtoEntry]
  def create_entry(proto_entry)
    entry = book.new_entry(proto_entry.text, proto_entry.date, proto_entry.digest)
    entry.connection = connection
    entry.save!
    log.puts "created"
  end

  # @param [ProtoEntry]
  def update_entry(proto_entry)
    book.update_entry(proto_entry.digest, proto_entry.text)
    log.puts "updated"
  end

  # @yieldparam [ProtoEntry]
  # @return [Array<ProtoEntry>]
  def proto_entries(&block)
    @proto_entries ||=
      if args.is_a?(Job::ConnectionDataPullBackfillArgs)
        connection.client.data_pull_backfill(&block)
      else
        connection.client.data_pull_standard(&block)
      end
  end

  # @return [Book]
  def book
    @book ||= connection.book
  end

  # @return [Connection]
  def connection
    @connection ||= Connection.find(args.connection_id)
  end

  # @return [Boolean]
  def oauth_client?
    connection.client.is_a? DataSource::OauthClient
  end
end
