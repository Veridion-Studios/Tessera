require "test_helper"

class PasskeysControllerTest < ActionDispatch::IntegrationTest
  test "session options are available without exposing a global allowlist" do
    post passkey_session_options_url, as: :json

    assert_response :success

    body = response.parsed_body
    assert body["challenge"].present?
    assert_equal [], body["allowCredentials"]
  end
end