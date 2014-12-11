require 'sinatra'
require 'oauth2'
require 'json'
require './app_helpers'
require "./app"

enable :sessions

get '/' do
  if session[:user]
    erb :'pulls/index'
  else
    erb :'login/index'
  end
end

get '/auth' do
  logout
  state = create_session_state
  session[:state] = state
  redirect "#{github_oath_path(state)}"
end

get '/auth.callback' do
  session[:user] = {id: 1, name: ''}
  redirect '/'
end

get '/logout' do
  logout
  redirect '/'
end
