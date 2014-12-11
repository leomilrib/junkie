helpers do
  def logout
    return unless session[:user]
    session[:user] = nil
  end
end
