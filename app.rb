require 'sinatra'
require 'octokit'
require 'httparty'
require 'json'
require 'evil_icons'
require './app_helpers'
require "./app"

helpers EvilIcons::Helpers

enable :sessions

get '/' do
  if session[:user]
    erb :'pulls'
  else
    erb :'login'
  end
end

get '/logout' do
  logout
  redirect '/'
end

get '/auth' do
  logout
  state = create_session_state
  session[:state] = state
  redirect "#{github_oath_path(state)}"
end

get '/auth.callback' do
  unless params[:code].to_s.empty? &&
    (params[:state].to_s.empty? || session[:state] != params[:state])

    query = {
      :body => {
        :client_id => ENV["GITHUB_APP_ID"],
        :client_secret => ENV["GITHUB_APP_SECRET"],
        :code => code
      },
      :headers => {
        "Accept" => "application/json"
      }
    }
    result = HTTParty.post("https://github.com/login/oauth/access_token", query)
    if result.code == 200
      begin
        token = JSON.parse(result.body)["access_token"]
        client = Octokit::Client.new(oauth_token: token)
      rescue => e
        error_and_back "github auth error"
      end

      session[:token] = token
      session[:user] = client.user
      session[:login] = client.user.login
      session[:avatar] = client.user.avatar_url
      session[:user_id] = client.user.id
    end
  end
  redirect '/'
end
