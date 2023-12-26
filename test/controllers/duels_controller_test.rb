require "test_helper"

class DuelsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get duels_index_url
    assert_response :success
  end

  test "should get new" do
    get duels_new_url
    assert_response :success
  end

  test "should get create" do
    get duels_create_url
    assert_response :success
  end

  test "should get update" do
    get duels_update_url
    assert_response :success
  end

  test "should get listing" do
    get duels_listing_url
    assert_response :success
  end

  test "should get pricing" do
    get duels_pricing_url
    assert_response :success
  end

  test "should get description" do
    get duels_description_url
    assert_response :success
  end

  test "should get media_upload" do
    get duels_media_upload_url
    assert_response :success
  end

  test "should get amenities" do
    get duels_amenities_url
    assert_response :success
  end

  test "should get location" do
    get duels_location_url
    assert_response :success
  end
end
