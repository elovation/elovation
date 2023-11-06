require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "gravatar" do
    it "uses a default image if the player doesn't have an email address" do
      player = FactoryBot.build(:player, email: "")

      helper.gravatar_url(player).should ==
        "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&s=32"
    end

    it "uses the player's gravatar url if he/she has an email address" do
      player = FactoryBot.build(:player, email: "test@example.com")

      helper.gravatar_url(player).should ==
        "http://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm&s=32"
    end

    it "can take a custom size" do
      player = FactoryBot.build(:player, email: "test@example.com")

      helper.gravatar_url(player, size: 64).should ==
        "http://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm&s=64"
    end
  end
end
