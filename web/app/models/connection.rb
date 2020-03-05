class Connection < ApplicationRecord
  include OwnerValidation

  belongs_to :user
  belongs_to :book, :optional => true
  has_many :credentials, :dependent => :destroy
  has_many :entries, :dependent => :destroy

  after_commit :schedule_data_pull_backfill, :if => :needs_initial_data_pull?

  validates :data_source, :user, :presence => true
  validate :book_is_owned_by_user, :if => :book_id

  scope :by_data_source, ->(ds) { find_by(:data_source => ds) }
  scope :last_update_attempted_over, ->(datetime) { where("last_update_attempted_at < ?", datetime) }
  scope :is_active, -> { where.not(:book_id => nil) }
  scope :in_random_order, -> { order("random()") }

  class MissingCredentialsError < StandardError; end

  # @return [DataSource::Client]
  def client
    raise MissingCredentialsError, "no credentials found for connection" unless newest_credentials

    @client ||=
      begin
        klass = DataSource::Client.for_data_source(data_source)
        klass.new(newest_credentials.options)
      end
  end

  # @return [Job]
  def schedule_data_pull_backfill
    schedule_data_pull(:connection_data_pull_backfill,
                       Job::ConnectionDataPullBackfillArgs.new(:connection_id => id))
  end

  # @return [Job]
  def schedule_data_pull_standard
    schedule_data_pull(:connection_data_pull_standard,
                       Job::ConnectionDataPullStandardArgs.new(:connection_id => id))
  end

private

  # @return [Credential, nil]
  def newest_credentials
    credentials.order("created_at desc").first
  end

  # @return [Boolean]
  def needs_initial_data_pull?
    book_id? && book_id_previously_changed?
  end

  # @return [Job]
  def schedule_data_pull(kind, args)
    Connection.transaction do
      update(:last_update_attempted_at => Time.now)
      Job.schedule!(user, kind, args)
    end
  end
end
