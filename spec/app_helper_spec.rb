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
    it 'returns true for issue that can be merged' do
      expect(can_merge_it?(time_line_approved_grouped_by_login)).to eq(true)
    end

    it 'returns false for issue that can not be merged yet' do
      expect(can_merge_it?(issue_needs_changes_grouped_by_login)).to eq(false)
    end
  end

  describe '#reviewed_it?' do
    it "returns false for logged user that didn't reviewed yet issue" do
      expect(
        reviewed_it?(issue_needs_changes_grouped_by_login)
      ).to eq(false)
    end

    it "returns true for logged user that reviewed issue already" do
      expect(
        reviewed_it?(time_line_approved_grouped_by_login)
      ).to eq(true)
    end
  end

  describe '#asked_for_changes?' do
    it "returns true for logged user that asked for changes on issue" do
      expect(
        asked_for_changes?(issue_needs_changes_grouped_by_login)
      ).to eq(true)
    end

    it "returns false for logged user that didn't asked for changes on issue" do
      expect(
        asked_for_changes?(time_line_approved_grouped_by_login)
      ).to eq(false)
    end
  end
end
