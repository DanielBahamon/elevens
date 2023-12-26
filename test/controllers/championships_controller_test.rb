require "test_helper"

class ChampionshipsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get championships_index_url
    assert_response :success
  end

  test "should get new" do
    get championships_new_url
    assert_response :success
  end

  test "should get create" do
    get championships_create_url
    assert_response :success
  end

  test "should get finance" do
    get championships_finance_url
    assert_response :success
  end

  test "should get visuals" do
    get championships_visuals_url
    assert_response :success
  end

  test "should get amenities" do
    get championships_amenities_url
    assert_response :success
  end

  test "should get location" do
    get championships_location_url
    assert_response :success
  end

  test "should get teams" do
    get championships_teams_url
    assert_response :success
  end

  test "should get show" do
    get championships_show_url
    assert_response :success
  end

  test "should get update" do
    get championships_update_url
    assert_response :success
  end
end
