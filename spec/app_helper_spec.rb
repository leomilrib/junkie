describe "app_helper" do
  include_context "octokit data"

  let!(:time_line_approved_grouped_by_login) {
    client
      .issue_timeline('organization/approved', 666)
      .group_by { |point| point[:user][:login] }
  }
  let!(:issue_needs_changes_grouped_by_login) {
    client
      .issue_timeline('organization/not_approved', 666)
      .group_by { |point| point[:user][:login] }
  }

  describe '#can_merge_it?' do
    it 'returns true if pull can be merged' do
      expect(can_merge_it?(time_line_approved_grouped_by_login)).to eq(true)
    end

    it 'returns false if pull can not be merged' do
      expect(can_merge_it?(issue_needs_changes_grouped_by_login)).to eq(false)
    end
  end

  describe '#reviewed_it?' do
    it "returns false if you didn't reviewed yet" do
      expect(reviewed_it?(issue_needs_changes_grouped_by_login)).to eq(false)
    end

    it "returns true if you reviewed it" do
      expect(reviewed_it?(time_line_approved_grouped_by_login)).to eq(true)
    end
  end

  describe '#comments?' do
    it "returns true if you commented it" do
      expect(comments?(time_line_approved_grouped_by_login)).to eq(true)
    end

    it "returns false if you didn't commented it" do
      expect(comments?(issue_needs_changes_grouped_by_login)).to eq(false)
    end
  end
end
