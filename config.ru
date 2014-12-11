set :session_secret, (ENV["SESSION_SECRET"] || "this is session secret")
run Sinatra::Application
