require "rails_helper"

describe ApplicationHelper, :type => :helper do
  describe "avatar_url" do
    it "uses a robohash of the player's name if they don't have an email address" do
      player = FactoryBot.build(:player, name: "Drew", email: "")
      digest = Digest::MD5.hexdigest("Drew")

      expect(helper.avatar_url(player)).to eq("https://robohash.org/#{digest}?size=32x32")
    end

    it "uses the player's gravatar via robohash if they have an email address" do
      player = FactoryBot.build(:player, email: "test@example.com")

      expect(helper.avatar_url(player)).to eq("https://robohash.org/55502f40dc8b7c769880b10874abc9d0?gravatar=hashed&size=32x32")
    end

    it "can take a custom size" do
      player = FactoryBot.build(:player, email: "test@example.com")

      expect(helper.avatar_url(player, size: 64)).to eq("https://robohash.org/55502f40dc8b7c769880b10874abc9d0?gravatar=hashed&size=64x64")
    end
  end
end
