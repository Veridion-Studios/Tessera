require "test_helper"

class DeveloperProfileTest < ActiveSupport::TestCase
  test "github access tokens are encrypted at rest and still readable" do
    profile = DeveloperProfile.create!(
      user: users(:one),
      connect_onboarding_status: "pending",
      verification_status: "unverified"
    )

    profile.update!(github_access_token: "plain-token-123")

    assert_not_equal "plain-token-123", profile.reload[:github_access_token]
    assert_equal "plain-token-123", profile.github_access_token
  end

  test "legacy plaintext github tokens remain readable" do
    profile = DeveloperProfile.create!(
      user: users(:two),
      connect_onboarding_status: "pending",
      verification_status: "unverified"
    )

    profile.update_columns(github_access_token: "legacy-token")

    assert_equal "legacy-token", profile.reload.github_access_token
  end
end
