class SessionsController < ApplicationController
  # so the mobile app can create a session
  # protect_from_forgery :except => [:create,:destroy]
  
  def new
    @title = "Sign in"
    @user = User.new
  end

  def create
    auth_hash = request.env['omniauth.auth']

    if auth_hash.nil?
      flash[:error] = "Authentication failure"
      redirect_to signin_path
    else
      provider = auth_hash["provider"]

      if signed_in? # session[:user_id]
        # Means our user is signed in. Add the authorization to the user
        # User.find(session[:user_id]).add_provider(auth_hash)
        current_user.add_provider(auth_hash)

        respond_to do | format |
          format.html do
            flash[:success] = "Signed in to #{provider}"
            redirect_to root_path
          end
        end
      else
        # Log him/her in or sign him/her up
        # Note that this find/creates an authorization AND also update the credentials
        # AND this will create a user that this authorization belongs to if an authorization
        # is created.
        # TODO: consider creating a User as a separate step
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
              redirect_to signin_path
            end
          end
        end
      end
    end
  end

  def failure
    flash[:error] = "Authentication failure"
    redirect_to signin_path
  end

  def destroy
    services = ""
    if params.include?(:provider)
      sign_out_of(params[:provider])
      services = params[:provider]
    else
      sign_out
      services = "all"
    end
    respond_to do | format |
      format.html do
        flash[:success] = "Signed out of #{services}"
        redirect_to root_path
      end
    end
  end
end
