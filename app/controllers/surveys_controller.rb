class SurveysController < ApplicationController
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
    # @word_counts = responses.cleaned_entry.
  end

  # when users are taking a survey. this corresponds to the 'get' action
  def input
    @survey = Survey.find(params[:id])

  end

  # when users are taking a survey. this corresponds to the 'put' action
  def add_input
    @survey = Survey.find(params[:id])

    @response = Response.new(survey_id: @survey.id, entry: params[:entry])
    if @response.save
      flash[:notice] = "Thank you for your input!"
      redirect_to @survey
    else
      redirect_back_or root_path
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
    @survey = Survey.new(:closing_time => DateTime.parse(survey_params[:closing_time]),
                         :max_responses => survey_params[:max_responses],
                         :question => survey_params[:question])
    respond_to do | format |
      if @survey.save
        format.html { redirect_to @survey, notice: "Your new survey was created! PIN: #{@survey.survey_pin}" }
      else
        format.html { render :new }
      end
    end
  end

  private
  def survey_params
    params.require(:survey).permit(:is_public, :closing_time, :max_responses, :question)
  end
end
