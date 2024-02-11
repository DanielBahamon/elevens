require "test_helper"

class FieldsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get fields_index_url
    assert_response :success
  end

  test "should get show" do
    get fields_show_url
    assert_response :success
  end

  test "should get new" do
    get fields_new_url
    assert_response :success
  end

  test "should get edit" do
    get fields_edit_url
    assert_response :success
  end
end
