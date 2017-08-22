require "spec_helper"

RSpec.describe Subdb::Cli do
  it "has a version number" do
    expect(Subdb::Cli::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
