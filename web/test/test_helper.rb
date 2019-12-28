ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require_relative "../config/environment"
require "rails/test_help"
require_relative "./processor_test_helper"

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def user
    @user ||= create(:user)
  end

  def book
    @book ||= create(:book, :user => user)
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize(:workers => :number_of_processors)

  parallelize_setup do |worker|
    SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
  end

  parallelize_teardown do
    SimpleCov.result
  end
end
