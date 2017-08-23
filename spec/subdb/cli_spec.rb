require "spec_helper"
require "tempfile"

RSpec.describe Subdb::Cli do

  subject { Subdb::Cli.new }

  before do
    @tmp_video_file = Tempfile.new('file')
    @tmp_video_file.write('\0' * Subdb::Cli::READSIZE * 2)
  end

  after do
    @tmp_video_file.close
    @tmp_video_file.unlink
  end

  it "has a version number" do
    expect(Subdb::Cli::VERSION).not_to be nil
  end

  describe "#download" do
    it "raises Subdb::Cli::FileNotFound if fails to open the video file" do
      expect do
        subject.download("/not/existing/path", "en")
      end.to raise_error(Subdb::Cli::FileNotFound)
    end

    it "raises Subdb::Cli::ErrorCalculatingHash if fails on hash calculation" do
      expect do
        subject.download(__FILE__, "en")
      end.to raise_error(Subdb::Cli::ErrorCalculatingHash)
    end

    it "sends download action to SubDB api" do
      stub = stub_request(:get, Subdb::Cli::BASE_URL)
        .with(query: hash_including({
          action: 'download',
          hash: '1e621d8c0bec682af06e45f34ecef898'
        }))
      subject.download(@tmp_video_file, "en")
      expect(stub).to have_been_requested
    end
  end

  describe "#upload" do
    it "raises Subdb::Cli::FileNotFound if fails to open the video file" do
      expect do
        subject.upload("/not/existing/path", __FILE__)
      end.to raise_error(Subdb::Cli::FileNotFound)
    end

    it "raises Subdb::Cli::FileNotFound if fails to open the srt file" do
      expect do
        subject.upload(@tmp_video_file, "/not/existing/path")
      end.to raise_error(Subdb::Cli::FileNotFound)
    end

    it "raises Subdb::Cli::ErrorCalculatingHash if fails on hash calculation" do
      expect do
        subject.upload(__FILE__, __FILE__)
      end.to raise_error(Subdb::Cli::ErrorCalculatingHash)
    end

    it "sends upload action to SubDB api" do
      stub = stub_request(:post, "#{Subdb::Cli::BASE_URL}?action=upload")
        .with(body: hash_including({
          hash: '1e621d8c0bec682af06e45f34ecef898'
        }))
      subject.upload(@tmp_video_file, __FILE__)
      expect(stub).to have_been_requested
    end
  end

end
