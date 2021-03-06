module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def remember user
    user.remember
    permanent = cookies.permanent
    permanent.signed[:user_id] = user.id
    permanent[:remember_token] = user.remember_token
  end

  def current_user
    session_id = session[:user_id]
    cookies_id = cookies.signed[:user_id]

    if session_id
      @current_user ||= User.find_by id: session_id
    elsif cookies_id
      authenticate_user cookies_id
    end
  end

  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete :forwarding_url
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  private

  def authenticate_user cookies_id
    user = User.find_by id: cookies_id

    return unless user && user.authenticated?(:remember,
      cookies[:remember_token])
    log_in user
    @current_user = user
  end
end
