class SchedulePullJob
  prepend SimpleCommand

  # @param [Connection]
  def initialize(connection)
    @connection = connection
  end

  def call
    Job.create!(:user => user,
                :connection => connection,
                :kind => :pull,
                :args => args)
  end

private

  attr_reader :connection

  delegate :id, :to => :connection, :private => true
  delegate :user, :to => :connection, :private => true

  def args
    ExecutePullJob::Arguments.new(:connection_id => id)
  end
end
