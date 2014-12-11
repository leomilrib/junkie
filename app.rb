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
  redirect '/auth.callback'
end

get '/auth.callback' do
  session[:user] = {id: 1, name: 'leo'}
  redirect '/'
end

get '/logout' do
  logout
  redirect '/'
end
