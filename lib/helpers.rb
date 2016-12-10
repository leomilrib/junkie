module Helpers
  APPROVED = 'approved'
  CHANGES_REQUESTED = 'changes_requested'

  def logout
    return unless session[:user]
    session[:user] = nil
    session[:token] = nil
  end

  def app_root
    "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}"
  end

  def big_ass_random_string
    ENV['SESSION_SATTE'] || "This is a big ass string yeah..."
  end

  def create_session_state
    Digest::MD5.hexdigest "#{Time.now.to_i}#{big_ass_random_string}#{rand}"
  end

  def github_oath_path(state)
    query = {
      :client_id => ENV["GITHUB_APP_ID"],
      :redirect_uri => "#{app_root}/auth.callback",
      :state => state,
      :scope => 'repo'
    }.map{ |k,v|
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

  def can_merge_it?(grouped_time_line)
    grouped_time_line.count { |user_login, time_lines|
      time_lines.any? { |time_line| time_line[:state] == APPROVED }
    } > 4
  end

  def reviewed_it?(user_time_line)
    ready = issue_comments.select { |ic|
      (ic[:user][:id] == session[:user_id]) && SHIPS_REGEX.match(ic[:body])
    }

    (ready.size > 0)
  end

  def asked_for_changes?(user_time_line)
    commented = pull_comments.select { |pc|
      pc[:user][:id] == session[:user_id]
    }

    (commented.size > 0)
  end

  def icon_merge(grouped_time_line)
    can_merge_it?(grouped_time_line) ? 'merge ready' : 'merge pending'
  end

  def icon_review(grouped_time_line)
    reviewed_it?(grouped_time_line[session[:user]]) ? 'review ready' : 'review pending'
  end

  def icon_comment(grouped_time_line)
    asked_for_changes?(grouped_time_line[session[:user]]) ? 'comment ready' : 'comment pending'
  end

  def responsible_info(pull)
    responsible = pull[:assignee] || pull[:user]

    <<-HTML
      <a href="#{responsible[:html_url]}">
        #{responsible[:login]}
      </a>
    HTML
  end
end
