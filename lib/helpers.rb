module Helpers
  APPROVED = 'approved'
  CHANGES_REQUESTED = 'changes_requested'
  EVENT_REVIEWD = 'reviewed'

  def logout
    return unless session[:user]
    session[:user] = nil
    session[:token] = nil
  end

  def app_root
    "https://#{env['HTTP_HOST']}"
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

  def can_merge_it?(grouped_timeline)
    grouped_timeline.count { |user_login, time_lines|
      time_lines.any? { |time_line| time_line[:state] == APPROVED }
    } > 4
  end

  def reviewed_it?(grouped_timeline)
    user_timeline = grouped_timeline[session[:user]] || []

    user_timeline.any? { |time_line|
      time_line[:state] == APPROVED
    }
  end

  def asked_for_changes?(grouped_timeline)
    user_timeline = grouped_timeline[session[:user]] || []

    user_timeline.any? { |time_line|
      time_line[:state] == CHANGES_REQUESTED
    }
  end

  def icon_merge(grouped_timeline)
    can_merge_it?(grouped_timeline) ? 'merge ready' : 'merge pending'
  end

  def icon_review(grouped_timeline)
    reviewed_it?(grouped_timeline) ? 'review ready' : 'review pending'
  end

  def icon_comment(grouped_timeline)
    asked_for_changes?(grouped_timeline) ? 'comment ready' : 'comment pending'
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
