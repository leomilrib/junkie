module Helpers
  def logout
    return unless session[:user]
    session[:user] = nil
    session[:token] = nil
  end

  def app_root
    "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}"
  end

  def create_session_state
    Digest::MD5.hexdigest "#{Time.now.to_i}unguessable random string#{rand}"
  end

  def github_oath_path(state)
    query = {
      :client_id => ENV["GITHUB_APP_ID"],
      :redirect_uri => "#{app_root}/auth.callback",
      :state => state,
      :scope => 'repo'
    }.map{|k,v|
      "#{k}=#{URI.encode(v)}"
    }.join("&")

    "https://github.com/login/oauth/authorize?#{query}"
  end

  def error_and_back(error)
    session[:error] = error.to_s
    redirect '/'
  end

  def set_client
    begin
      if settings.development?
        client = Octokit::Client.new(:netrc => true)
      else
        client = Octokit::Client.new(access_token: session[:token])
      end
    rescue => e
      error_and_back 'GitHub auth error...'
    end

    session[:user] = client.user.login
    session[:avatar] = client.user.avatar_url
    session[:user_id] = client.user.id
    client
  end

  def can_merge_it?(issue_comments)
    ships_regex = /(:\+1:)|(:shipit:)/

    approves = issue_comments.select { |ic|
      ships_regex.match ic[:body]
    }

    approves.size > 1 ? true : false
  end

  def reviewed_it?(issue_comments)
    ships_regex = /(:\+1:)|(:shipit:)/
    ready = issue_comments.select { |ic|
      (ic[:user][:id] == session[:user_id]) && ships_regex.match(ic[:body])
    }

    ready.size > 0 ? true : false
  end

  def comments?(pull_comments)
    pull_comments.size > 0 ? true : false
  end

  def icon_merge(pull)
    can_merge_it?(pull[:issue_comments]) ? 'merge ready' : 'merge pending'
  end

  def icon_review(pull)
    reviewed_it?(pull[:issue_comments]) ? 'review ready' : 'review pending'
  end

  def icon_comment(pull)
    comments?(pull[:pull_comments]) ? 'comment ready' : 'comment pending'
  end
end
