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

get '/' do
  if session[:user]
    @client = set_client
    query = "involves:#{@client.user.login} is:pr is:open"
    @orgs_pulls = @client.search_issues(query).items
    @orgs_pulls.each { |org_pull|
      regex = /.+repos\/(?<org>.+)\/(?<repo>.+)\/pulls\/(?<number>\d+)/
      captures = org_pull.pull_request.url.match(regex)
      org_pull[:org] = captures[:org]
      org_pull[:repo] = captures[:repo]
      org_pull[:number] = captures[:number]
      org_pull[:issue_comments] = begin
         @client.issue_comments("#{org_pull[:org]}/#{org_pull[:repo]}",
          "#{org_pull[:number]}")
      rescue
         []
      end

      org_pull[:pull_comments] = begin
        @client.pull_comments("#{org_pull[:org]}/#{org_pull[:repo]}",
          "#{org_pull[:number]}")
      rescue
        []
      end
     }
     @orgs_pulls = @orgs_pulls.group_by { |op| op[:org] }

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
  unless params[:code].to_s.empty? &&
    (params[:state].to_s.empty? || session[:state] != params[:state])

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
      result = HTTParty.post("https://github.com/login/oauth/access_token", query)
      if result.code == 200
        session[:token] = JSON.parse(result.body)["access_token"]
        client = set_client
      end
    end
    redirect '/'
  end
