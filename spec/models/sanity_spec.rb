require "spec_helper"

describe "sanity" do
  describe "frozen mirations" do
    it "ensures deployed migrations have not changed" do
      migrations_digests = {
        "001_release_001.rb" => "417a34264a312cff3ee307b900cd87a8",
        "002_release_002.rb" => "0ddd93962d29f8f733f61ef1da7b4b1b",
        "003_release_003.rb" => "3efa7a07f92d33320aa5e774831935e6",
        "004_release_004.rb" => "5f68e784abd9cd501ee427391143fced",
        "005_release_005.rb" => "60786017f6794a6b4db80e54f6a480bc",
        "006_release_006.rb" => "a2dde6fb6d8f9ec7dce5d5d3091b8789",
        "007_release_007.rb" => "daab8b04d735229dfd88805822f6b471",
      }

      migrations_digests.each do |migration, digest|
        contents = File.read(Rails.root.join("db", "migrate", migration))

        Digest::MD5.hexdigest(contents).should == digest
      end
    end
  end
end
