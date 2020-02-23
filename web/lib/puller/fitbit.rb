class Puller::Fitbit < Puller::OauthClient
  Steps = Struct.new(:date, :value, :keyword_init => true) do
    # @param [Hash] result
    # @return [Steps]
    def self.from_result(result)
      new(:date => Date.parse(result["dateTime"]),
          :value => result["value"].to_i)
    end
  end

  HeartRate = Struct.new(:date, :value, :keyword_init => true) do
    # @param [Hash] result
    # @return [HeartRate]
    def self.from_result(result)
      new(:date => Date.parse(result["dateTime"]),
          :value => result["value"]["restingHeartRate"])
    end
  end

  # @param [Hash] options
  def initialize(options = {})
    client(options)
  end

  # @return [String]
  def auth_url
    client.auth_url
  end

  # @param [String] code
  def code=(code)
    client.get_token(code)
    @user_id = client.token["user_id"]
  end

  # @return [Hash]
  def serialize_token
    token = client.token
    {
      :user_id => user_id,
      :access_token => token.token,
      :refresh_token => token.refresh_token,
      :expires_at => token.expires_at,
    }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<HeartRate>]
  def heart_rate_time_series(start_date: Date.today, end_date: start_date)
    client.heart_rate_time_series(:start_date => start_date, :end_date => end_date)
          .filter { |result| result["value"]["restingHeartRate"] }
          .map { |result| HeartRate.from_result(result) }
  end

  # @param [Date] start_date
  # @param [Date] end_date
  # @return [Array<Steps>]
  def steps_time_series(start_date: Date.today, end_date: start_date)
    client.activity_time_series("tracker/steps", :start_date => start_date, :end_date => end_date)
          .filter { |result| result["value"] && result["value"] != "0" }
          .map { |result| Steps.from_result(result) }
  end

private

  attr_accessor :user_id

  # @param [Hash] options
  # @return [::FitbitAPI::Client]
  def client(options = {})
    conf = config(options)
    @user_id = conf["user_id"]
    @client ||= ::FitbitAPI::Client.new(conf)
  end

  # @param [Hash] options
  #
  # @option [String] user_id
  # @option [String] access_token
  # @option [String] refresh_token
  # @option [Integer] expires_at
  #
  # @return [Hash]
  def config(options = {})
    options.merge(::Rails.application.config.fitbit).with_indifferent_access
  end
end
