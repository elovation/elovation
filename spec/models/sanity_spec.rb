require "spec_helper"

describe "sanity" do
  describe "frozen mirations" do
    it "ensures deployed migrations have not changed" do
      migrations_digests = {
        "001_release_001.rb" => "a893705e0162076ba9416f805b13362e",
        "002_release_002.rb" => "ee6c0915268eca0f8a317c1a7e2048be",
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
