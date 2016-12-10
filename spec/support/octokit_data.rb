shared_context "octokit data" do

  let(:client) { instance_double('Octokit::Client') }
  let(:session) {
    session = {
      user: "logged_user",
      user_id: 666667
    }
  }

  before do
    allow(client).to receive(:issue_timeline)
      .with('organization/approved', 666)
      .and_return([
        { user: { login: "logged_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "another_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "one_more_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "user_too" }, state: 'approved', event: "reviewed" },
        { user: { login: "aaand_one_more" }, state: 'approved', event: "reviewed" }
      ]
    )

    allow(client).to receive(:issue_timeline)
      .with('organization/not_approved', 666)
      .and_return([
        { user: { login: "user" }, state: 'approved', event: "reviewed" },
        { user: { login: "another_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "one_more_user" }, state: 'approved', event: "reviewed" },
        { user: { login: "logged_user" }, state: 'changes_requested', event: "reviewed" },
        { user: { login: "user_asked_changes_too" }, state: 'changes_requested', event: "reviewed" }
      ]
    )
  end
end
