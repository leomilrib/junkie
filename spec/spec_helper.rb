ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'capybara/dsl'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require File.expand_path '../../app.rb', __FILE__
Dir["./spec/support/**/*.rb"].each { |f| require f }

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c|
  c.include RSpecMixin
  c.include Capybara::DSL
  c.include Helpers
  c.shared_context_metadata_behavior = :apply_to_host_groups
}

Capybara.app = Sinatra::Application
