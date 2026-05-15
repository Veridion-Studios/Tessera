require "test_helper"

class PortfolioSubmissionTest < ActiveSupport::TestCase
  test "project demo url rejects newline injection" do
    submission = PortfolioSubmission.new(
      user: users(:one),
      title: "Demo",
      github_repo_url: "https://github.com/example/project",
      status: "pending",
      project_demo_url: "https://example.com\njavascript:alert(1)"
    )

    assert_not submission.valid?
    assert_includes submission.errors[:project_demo_url], "must be a valid URL"
  end

  test "project demo url accepts a normal https url" do
    submission = PortfolioSubmission.new(
      user: users(:one),
      title: "Demo",
      github_repo_url: "https://github.com/example/project",
      status: "pending",
      project_demo_url: "https://example.com/demo"
    )

    assert submission.valid?
  end
end
