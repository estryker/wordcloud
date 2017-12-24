require 'test_helper'

class SurveyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get survey_index_url
    assert_response :success
  end

  test "should get results" do
    get survey_results_url
    assert_response :success
  end

  test "should get input" do
    get survey_input_url
    assert_response :success
  end

  test "should get admin" do
    get survey_admin_url
    assert_response :success
  end

  test "should get new" do
    get survey_new_url
    assert_response :success
  end

end
