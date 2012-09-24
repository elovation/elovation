require "spec_helper"

describe Notify do
  describe "challenge_email" do
    let(:challenge) { FactoryGirl.create(:challenge) }
    let(:mail) { Notify.challenge_email('http://somewhere', challenge) }

    it "renders subject" do
      mail.subject.should == "You have been challenged in #{challenge.game.name}"
    end

    it "renders the receiver email" do
      mail.to.should == [challenge.challengee.email]
    end

    it "renders the sender email" do
      mail.from.should == [challenge.challenger.email]
    end

    it "mentions challenger and game" do
      mail.body.encoded.should match("#{challenge.challenger.name}.*challenged.*#{challenge.game.name}")
    end

    it "mentions expiration" do
      mail.body.encoded.should match("expire.*#{challenge.expires_at.to_s(:short)}")
    end

    it "includes game url" do
      mail.body.encoded.should match("http://somewhere/games/#{challenge.game_id}")
    end
  end
end
