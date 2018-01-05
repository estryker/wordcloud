class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  

  def facebook
    generic_callback( 'facebook' )
  end

  def twitter
    generic_callback( 'twitter' )
  end

  def google_oauth2
    generic_callback( 'google_oauth2' )
  end

  def generic_callback( provider )
    puts "Signing in to #{provider}"
    
    auth_hash = request.env['omniauth.auth']
    
    if auth_hash.nil?
      puts "Authentication error" 
      flash[:error] = "Authentication failure"
      redirect_to new_user_session_path
    else
      auth_provider = auth_hash["provider"]

      if signed_in? # session[:user_id]
        puts "Already signed in, adding provider ..."
        # Means our user is signed in. Add the authorization to the user
        # User.find(session[:user_id]).add_provider(auth_hash)
        current_user.add_provider(auth_hash)

        respond_to do | format |
          format.html do
            puts "now signed in to #{auth_provider}"
            flash[:success] = "Signed in to #{auth_provider}"
            redirect_to root_path
          end
        end
      else
        # Log him/her in or sign him/her up
        # Note that this find/creates an authorization AND also update the credentials
        # AND this will create a user that this authorization belongs to if an authorization
        # is created.
        # TODO: consider creating a User as a separate step
        puts "Not signed in, checking authorizations"
        auth = Authorization.find_or_create(auth_hash)
        
        if auth.user
          # authorizations belong to users, so ActiveRecord must do this lookup for us.
          sign_in auth.user
          
          respond_to do | format |
            format.html do
              flash[:success] = "Signed in to #{provider}"
              redirect_back_or root_path
            end
          end
        else
          # This is an internal error that shouldn't happen. i.e. we'd have to debug, as opposed to asking the user to do something else
          respond_to do | format |
            format.html do
              flash[:error] = "Internal error. Couldn't authorize"
              redirect_to new_user_session_path
            end
          end
        end
      end
    end
  end

  def after_sign_in_path_for(resource)
    if resource.email_verified?
      super resource
    else
      # mainly for twitter users
      finish_signup_path(resource)
    end
  end
end

=begin rdoc

From:
http://willschenk.com/setting-up-devise-with-twitter-and-facebook-and-other-omniauth-schemes-without-email-addresses/

    @identity = Identity.find_for_oauth env["omniauth.auth"]

    @user = @identity.user || current_user
    if @user.nil?
      @user = User.create( email: @identity.email || "" )
      @identity.update_attribute( :user_id, @user.id )
    end

    if @user.email.blank? && @identity.email
      @user.update_attribute( :email, @identity.email)
    end

    if @user.persisted?
      @identity.update_attribute( :user_id, @user.id )
      # This is because we've created the user manually, and Device expects a
      # FormUser class (with the validations)
      @user = FormUser.find @user.id
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.capitalize) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end


=end
