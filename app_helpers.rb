helpers do
  def logout
    return unless session[:user]
    session[:user] = nil
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
      :state => state
    }.map{|k,v|
      "#{k}=#{URI.encode(v)}"
    }.join("&")

    "https://github.com/login/oauth/authorize?#{query}"
  end

  def error_and_back(error)
    session[:error] = error.to_s
    redirect '/'
  end

end
