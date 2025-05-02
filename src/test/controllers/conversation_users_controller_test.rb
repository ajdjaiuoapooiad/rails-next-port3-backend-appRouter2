require "test_helper"

class ConversationUsersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get conversation_users_create_url
    assert_response :success
  end

  test "should get destroy" do
    get conversation_users_destroy_url
    assert_response :success
  end
end
