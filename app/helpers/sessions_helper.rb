module SessionsHelper
  # Note that this needs to be included into a controller or else all the redirect methods won't work 
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end   
 
  def deny_access
    store_location
    redirect_to new_user_session_path, :notice => "Please sign in to access this page."
  end

  # still not 100% sure how this will interact with devise
  def signed_in_to?(service)
    signed_in? and  current_user.authorizations.any? {|a| a.provider.to_s == service.to_s and not a.token.nil? }
  end
  
  # TODO: make sure it is okay to hold on to these tokens even if signed out of devise stuff
  # **Note** that uncommenting this covers up the devise function of the same name. 
  #
  # signs people out of all services
  # def sign_out
  #  current_user.authorizations.each do | a |
  #    a.token = nil
  #    a.secret = nil
  #    a.save
  #  end
  #  current_user = nil
  #  session[:user_id] = nil
  # end

  def sign_out_of(service)
     # there should only be one. But for now, just set them all to nil
     current_user.authorizations.where(:provider => service).each do | a |
      a.token = nil
      a.secret = nil
      a.save
     end
    
    # only sign_out of the session after all services are signed out of
    if current_user.authorizations.all? {|a| a.token.nil? }
      # current_user = nil
      # session[:user_id] = nil
      # ** Using the sign_out function from Devise
      sign_out
    end

  end

  private

  def store_location
    session[:return_to] = request.fullpath
  end
  
  def clear_return_to
    session[:return_to] = nil
  end
end
