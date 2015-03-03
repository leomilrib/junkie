ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'capybara/dsl'
require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c|
  c.include RSpecMixin
  c.include Capybara::DSL
  c.include Helpers
}

Capybara.app = Sinatra::Application
