describe "app_helper" do
  include_context "octokit data"

  it 'returns true if pull can be merged' do
    result = can_merge_it?(octo_client_ready.issue_timeline('org/repo',666))

    expect(result).to be_truthy
  end

  it 'returns false if pull can not be merged' do
    result = can_merge_it?(octo_client_not_ready.issue_timeline('org/repo',666))

    expect(result).to be_falsey
  end

  it "returns false if you didn't reviewed yet" do
    result = reviewed_it?(octo_client_not_ready.issue_timeline('org/repo',666))

    expect(result).to be_falsey
  end

  it "returns true if you reviewed it" do
    result = reviewed_it?(octo_client_ready.issue_timeline('org/repo',666))

    expect(result).to be_truthy
  end

  it "returns true if you commented it" do
    result = comments?(octo_client_ready.issue_timeline('org/repo',666))

    expect(result).to be_truthy
  end

  it "returns false if you didn't commented it" do
    result = comments?(octo_client_not_ready.issue_timeline('org/repo',666))

    expect(result).to be_falsey
  end
end
