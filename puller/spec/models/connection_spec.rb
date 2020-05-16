describe Connection do
  subject { described_class.create_with_credentials(connection_attrs, credentials_hash) }

  let(:connection_attrs) do
    {
      :source => :lastfm,
      :user => create(:user)
    }
  end

  let(:credentials_hash) do
    {
      :user => :minond
    }
  end

  describe "callbacks" do
    describe "after_create" do
      it "creates a job" do
        expect { subject }.to change { Job.count }.by 1
      end
    end
  end

  describe ".create_with_credentials" do
    it "creates the credentials" do
      expect { subject }.to change { Connection.count }.by 1
    end

    it "creates the credentials" do
      expect { subject }.to change { Credential.count }.by 1
    end
  end

  describe "#client" do
    it "returns the expected client class" do
      expect(subject.client).to be_a Source::Lastfm
    end

    it "authenticates the client with the latests credentials" do
      expect(subject.client.credential_options).to include credentials_hash
    end
  end

  describe "#schedule_backfill" do
    it "creates a job" do
      subject
      expect { subject.schedule_backfill }.to change { Job.count }.by 1
    end
  end

  describe "#schedule_pull" do
    it "creates a job" do
      subject
      expect { subject.schedule_pull }.to change { Job.count }.by 1
    end
  end

  describe "#recent_stats" do
    before do
      create(:job, :done, :connection => subject)
      create(:job, :done, :connection => subject)
      create(:job, :errored, :connection => subject)
      create(:job, :running, :connection => subject)
    end

    let(:recent_stats) { subject.recent_stats }
    let(:recent_stats_statuses) { recent_stats.map(&:second) }

    it "returns recent job information" do
      expect(recent_stats_statuses).to match_array %w[done done errored running initiated]
    end
  end
end
