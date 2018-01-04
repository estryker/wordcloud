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

    @response = Response.new(survey_id: @survey.id, entry: params[:entry])
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
