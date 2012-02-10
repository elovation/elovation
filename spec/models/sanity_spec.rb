require "spec_helper"

describe "sanity" do
  describe "frozen mirations" do
    it "ensures deployed migrations have not changed" do
      migrations_digests = {
        "001_release_001.rb" => "55d3fa3763a8ebaac18b8c1a9ff7f053",
        "002_release_002.rb" => "983bbaf2307fd7c00f34a2242e5498b2"
      }

      migrations_digests.each do |migration, digest|
        contents = File.read(Rails.root.join("db", "migrate", migration))

        Digest::MD5.hexdigest(contents).should == digest
      end
    end
  end
end
