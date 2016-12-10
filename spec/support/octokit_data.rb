shared_context "octokit data" do
  let(:octo_client_ready) {
    instance_double('Octokit::Client',
      issue_timeline: [
        { user: { login: "user" }, state: 'approved', event: "reviewed" },
        { user: { login: "another_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "one_more_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "user_too" }, state: 'approved', event: "reviewed" },
        { user: { login: "aaand_one_more" }, state: 'approved', event: "reviewed" }
      ]
    )
  }

  let(:octo_client_not_ready) {
    instance_double('Octokit::Client',
      issue_timeline: [
        { user: { login: "user" }, state: 'approved', event: "reviewed" },
        { user: { login: "another_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "one_more_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "user_asked_for_changes" }, state: 'changes_requested', event: "reviewed" },
        { user: { login: "user_asked_changes_too" }, state: 'changes_requested', event: "reviewed" }
      ]
    )
  }

  let(:session) {
    session = {
      user: "user",
      user_id: 666667
    }
  }
end
