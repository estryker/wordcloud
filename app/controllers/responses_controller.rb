class ResponsesController < ApplicationController
  include SessionsHelper

  before_action :set_survey, :only => [:show, :new, :create, :check_timeout, :edit, :update, :index,:check_user]
  before_action :authenticate, :only => [:edit, :update, :index]
  before_action :check_user, :only => [:edit, :update]
  before_action :check_admin, :only => [:index]
  before_action :set_response, :only => [:show, :edit, :update]
  before_action :check_public, :only => [:new, :create]
  before_action :check_timeout, :only => [:new, :create]

  def index
    @responses = @survey.responses 
  end
  
  # when users are taking a survey. this corresponds to the 'get' action
  def new
    # @survey = Survey.find(params[:id])
    @response = Response.new
  end

  # when users are taking a survey. this corresponds to the 'put' action
  def create
    # @survey = Survey.find(params[:id])

    input_user = (current_user || helpers.anonymous_user)
    
    @response = Response.new(survey_id: @survey.id, entry: response_params[:entry], user_id: input_user.id)
    if @response.save
      flash[:notice] = "Thank you for your input!"
      redirect_to @survey
    else
      flash[:error] = "Couldn't add input: #{@response.errors.messages}"
      redirect_back(fallback_location: root_path)
    end
  end

  def edit

  end

  def update
    @response.entry = response_params[:entry]
    if @response.save
      flash[:notice] = "Thank you for your input!"
      redirect_to @survey
    else
      flash[:error] = "Couldn't add input: #{@response.errors.messages}"
      redirect_back(fallback_location: root_path)
    end
  end
  
  private
  def set_survey
    @survey = Survey.find(params[:survey_id])
  end
  def set_response
    @response = Response.find(params[:id])
  end

  def response_params
    params.require(:response).permit(:entry)
  end

   def check_timeout
    # @survey = Survey.find(params[:id])
    if @survey.closing_time < Time.now
      flash[:error] = "Survey is closed"
      redirect_to(@survey)
    end
   end

   def authenticate
    # new in rails 5: no need to include individual helpers
    # helpers.
    # TODO: how do we get the application to redirect the user back to the page that they were on??
    deny_access unless signed_in? 
   end

  def check_public
    if current_user.nil? and not @survey.is_public 
      flash[:error] = "You must sign in to add input to that survey"
      store_location
      redirect_to(new_user_session_path)
    end
  end

  def check_timeout
    # @survey = Survey.find(params[:id])
    if @survey.closing_time < Time.now
      flash[:error] = "Survey is closed"
      redirect_to(@survey)
    end
  end
  def check_user
    deny_access unless current_user.id == @survey.user_id
  end
  def check_admin
    deny_access unless current_user.admin?
  end
end
