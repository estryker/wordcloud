class SurveyController < ApplicationController
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
  
  def results
  end

  # when users are taking a survey
  def input
    survey_pin = params[:id]
  end

  # when the creator wants to change something in an existing survey
  def admin
  end

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    respond_to do | format |
      if @survey.save
        format.html { redirect_to @survey, notice: "Your new survey was created! PIN: #{s.survey_pin}" }
      else
        format.html { render :new }
      end
    end
  end

  private
  def survey_params
    params.require(:open).permit(:duration_days)
  end
end
