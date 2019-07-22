require 'test_helper'

class UseflagsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, id: 'test'
    assert_response :success
  end

  test "should get search" do
    get :search, q: 'test'
    assert_response :success
  end

end
