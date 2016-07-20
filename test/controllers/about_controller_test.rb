require 'test_helper'

class AboutControllerTest < ActionController::TestCase
  test "should get feedback" do
    get :feedback
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
