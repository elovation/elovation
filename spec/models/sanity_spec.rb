require "spec_helper"

describe "sanity" do
  describe "frozen mirations" do
    it "ensures deployed migrations have not changed" do
      migrations_digests = {
        "001_release_001.rb" => "55d3fa3763a8ebaac18b8c1a9ff7f053",
        "002_release_002.rb" => "983bbaf2307fd7c00f34a2242e5498b2",
        "003_release_003.rb" => "ef70f4e0dd6214f426fdd162d56e88c4",
        "004_release_004.rb" => "152f9acaad9708d938d0d797084c2687"
      }

      migrations_digests.each do |migration, digest|
        contents = File.read(Rails.root.join("db", "migrate", migration))

        Digest::MD5.hexdigest(contents).should == digest
      end
    end
  end
end
