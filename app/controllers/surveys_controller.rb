class SurveysController < ApplicationController
  include SessionsHelper
  
  before_action :authenticate, :only => [:edit, :update, :new, :create]
  before_action :check_timeout, :only => [:input]
  
  def index
  end

  # either get here from direct URL or from a search box on the main page, or the survey overview page
  def survey
    @survey = Survey.find(params[:id])
    if @survey.nil?
      flash[:error] = "Survey not found"
      redirect_back_or root_path
    end
  end
  
  def show
    @survey = Survey.find(params[:id])
    responses = @survey.responses 
    puts "Response: \n" + responses.map {|r| r.cleaned_entry}.join("\n")
    # s.flat_map {|x| x.split(" ") }.group_by {|w| w}.map {|k,v| [k, v.length]}
    @word_counts = Hash.new(0)
    responses.flat_map {|r| r.cleaned_entry.split(" ")}.each {|word| @word_counts[word] += 1 }
  end

  def do_search
    pin = params[:survey_pin].strip
    if(s = Survey.find_by_survey_pin(pin))
       redirect_to s
    else
      flash[:error] = "No survey with pin: #{params[:survey_pin]} found ... try again"
      redirect_back(fallback_location: root_path)
    end
  end

  def search
    respond_to do | format |
      puts 'rendering search'
      format.html { render :search }
    end
  end
  
  # when users are taking a survey. this corresponds to the 'get' action
  def input
    @survey = Survey.find(params[:id])
  end

  # when users are taking a survey. this corresponds to the 'put' action
  def add_input
    @survey = Survey.find(params[:id])

    input_user = (current_user || anonymous_user)


    @response = Response.new(survey_id: @survey.id, entry: params[:entry], user_id: input_user.id)
    if @response.save
      flash[:notice] = "Thank you for your input!"
      redirect_to @survey
    else
      flash[:error] = "Couldn't add input: #{@response.errors.messages}"
      redirect_back(fallback_location: root_path)
    end
  end
  
  # when the creator wants to change something in an existing survey
  def admin
  end

  def new
    @survey = Survey.new
  end

  def create
    puts survey_params
    # DateTime.parse(survey_params[:closing_time]
    # Using e.g. "01/14/2018 4:30 PM"
    # DateTime.strptime("01/14/2018 04:30 PM", "%m/%d/%Y %I:%M %p")
    closing_time = DateTime.strptime(survey_params[:closing_time], "%m/%d/%Y %I:%M %p")

    max_responses = 1 
    if survey_params[:max_responses].downcase.include? "no limit"
      max_responses = 1_000_000
    elsif survey_params[:max_responses] =~ /^\d+/
      max_responses = survey_params[:max_responses]
    end
    @survey = Survey.new(:closing_time => closing_time,
                         :max_responses => max_responses,
                         :question => survey_params[:question])

    # Note that there must be a current_user b/c of the before_action
    @survey.user = current_user
    respond_to do | format |
      if @survey.save
        format.html { redirect_to @survey, notice: "Your new survey was created! PIN: #{@survey.survey_pin}" }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @survey = Survey.find(params[:id])
  end

  def update
    @survey = Survey.find(params[:id])
    # TODO: take the parameters and set new values
  end
  
  private
  def survey_params
    params.require(:survey).permit(:is_public, :closing_time, :max_responses, :question)
  end

  def authenticate
    # new in rails 5: no need to include individual helpers
    # helpers.
    # TODO: how do we get the application to redirect the user back to the page that they were on??
    deny_access unless signed_in? 
  end

  def check_timeout
    @survey = Survey.find(params[:id])
    if @survey.closing_time < Time.now
      flash[:error] = "Survey is closed"
      redirect_to(@survey)
    end
  end

end
