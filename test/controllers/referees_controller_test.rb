require "test_helper"

class RefereesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get referees_create_url
    assert_response :success
  end
end
