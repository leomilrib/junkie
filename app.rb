require 'sinatra'
require 'sinatra/flash'
require 'octokit'
require 'httparty'
require 'faraday-http-cache'
require 'json'
require './app_helpers'

enable :sessions
set :session_secret, (ENV["SESSION_SECRET"] || "this is session secret")

stack = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
Octokit.auto_paginate = true

get '/' do
  if session[:user]
    client = set_client
    # user_login = client.user.login
    user_login = session[:user]
    orgs = client.orgs << { login: user_login }
    users_orgs = orgs.map { |o| "user:#{o[:login]}"}.join(' ')
    query = "#{users_orgs} is:pr is:open -involves:#{user_login}"
    issues = [Thread.new { client.search_issues(query).items }]
    issues << Thread.new {
      client.search_issues("involves:#{user_login} is:pr is:open").items
    }
    url_regex = /.+repos\/(?<org>.+)\/(?<repo>.+)\/pulls\/(?<number>\d+)/
    @pulls = issues.flat_map { |issue|
      issue.value.each { |pull|
        captures = pull.pull_request.url.match(url_regex)
        pull[:org] = captures[:org]
        pull[:repo] = captures[:repo]
        pull[:number] = captures[:number]
      }
    }
    @pulls = @pulls.sort_by { |p|
      p[:org]
    }.group_by { |p|
      p[:org]
    }

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
  if settings.development?
    client = set_client
    redirect '/'
  else
    state = create_session_state
    session[:state] = state
    redirect "#{github_oath_path(state)}"
  end
end

get '/auth.callback' do
  unless(params[:code].to_s.empty? && (params[:state].to_s.empty? || session[:state] != params[:state]))
    query = {
      :body => {
        :client_id => ENV["GITHUB_APP_ID"],
        :client_secret => ENV["GITHUB_APP_SECRET"],
        :code => params[:code]
      },
      :headers => {
        "Accept" => "application/json"
      }
    }
    result = HTTParty.post(
      "https://github.com/login/oauth/access_token",
      query
    )
    if result.code == 200
      session[:token] = JSON.parse(result.body)["access_token"]
      client = set_client
    end
  end
  redirect '/'
end

get '/about' do
  erb :'about'
end

get '/pull_icons' do
  from_last_update = params[:updated_at]
  pull = {}
  client = set_client
  pull[:issue_comments] = begin
     client.issue_comments(
      "#{params[:org]}/#{params[:repo]}",
      "#{params[:number]}"
    )
  rescue
     []
  end
  pull[:pull_comments] = begin
    client.pull_comments(
      "#{params[:org]}/#{params[:repo]}",
      "#{params[:number]}",
      options: { since: from_last_update }
    )
  rescue
    []
  end

  erb :'_pull_icons', layout: false, locals: { pull: pull }
end
