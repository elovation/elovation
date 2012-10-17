require 'spec_helper'

describe ChallengesController do
  describe "new" do
    it "exposes a new challenge" do
      game = FactoryGirl.create(:game)

      get :new, :game_id => game

      assigns(:challenge).should_not be_nil
    end
  end

  describe "create" do
    context "with valid params" do
      it "creates a new challenge with the given players" do
        game = FactoryGirl.create(:game)
        player_1 = FactoryGirl.create(:player)
        player_2 = FactoryGirl.create(:player)

        post :create, :game_id => game, :challenge => {
          :challenger_id => player_1.id,
          :challengee_id => player_2.id,
        }

        game.reload.challenges.size.should == 1
        challenge = game.reload.challenges.first

        challenge.should_not be_nil
        challenge.game.should == game
        challenge.challenger.should == player_1
        challenge.challengee.should == player_2
        challenge.result.should be_nil
      end
    end

    it "sends email to challengee" do
        game = FactoryGirl.create(:game)
        player_1 = FactoryGirl.create(:player)
        player_2 = FactoryGirl.create(:player)

        post :create, :game_id => game, :challenge => {
          :challenger_id => player_1.id,
          :challengee_id => player_2.id,
        }

        ActionMailer::Base.deliveries.size.should == 1
        email = ActionMailer::Base.deliveries.first

        challenge = game.reload.challenges.first

        email.to.should == [challenge.challengee.email]
    end

    context "with invalid params" do
      it "renders the new page" do
        game = FactoryGirl.create(:game)
        player = FactoryGirl.create(:player)

        post :create, :game_id => game, :challenge => {
          :challenger_id => player.id,
          :challengee_id => player.id,
        }

        response.should render_template(:new)
      end
    end
  end

  describe "destroy" do
    it "deletes a challenge" do
      challenge = FactoryGirl.create(:challenge)

      delete :destroy, :game_id => challenge.game, :id => challenge

      response.should redirect_to(game_path(challenge.game))
      Challenge.find_by_id(challenge.id).should be_nil
    end
  end

  describe "expire" do
    it "generates results for expired challenges" do
      game_1 = FactoryGirl.create(:game)
      game_2 = FactoryGirl.create(:game)
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      player_3 = FactoryGirl.create(:player)

      active_challenge = FactoryGirl.create(:challenge, :game => game_1, :challenger => player_1, :challengee => player_2)

      time_1 = 6.days.ago
      time_2 = 5.days.ago

      Timecop.freeze(time_1) do
        FactoryGirl.create(:challenge, :game => game_1, :challenger => player_2, :challengee => player_3)
      end

      Timecop.freeze(time_2) do
        FactoryGirl.create(:challenge, :game => game_2, :challenger => player_2, :challengee => player_1)
      end

      post :expire_pending

      response.body.should == "2 challenges expired"

      Challenge.active.size.should == 1
      Challenge.active.first.should == active_challenge

      Challenge.inactive.size.should == 2

      Result.all.collect {|r| [r.winner.id, r.loser.id]}.should == [
        [player_2.id, player_3.id],
        [player_2.id, player_1.id]
      ]
    end

    it "creates results that can be destroyed" do
      game = FactoryGirl.create(:game)
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)

      Timecop.freeze(6.days.ago) do
        FactoryGirl.create(:challenge, :game => game, :challenger => player_1, :challengee => player_2)
      end

      post :expire_pending

      expect{ ResultService.destroy(Result.first) }.not_to raise_error
    end

    it "updates ratings" do
      game = FactoryGirl.create(:game)
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)

      ResultService.create(game, :winner_id => player_1.id, :loser_id => player_2.id).result

      player_1_rating = player_1.ratings.where(:game_id => game.id).first
      player_2_rating = player_2.ratings.where(:game_id => game.id).first

      old_rating_1 = player_1_rating.value
      old_rating_2 = player_2_rating.value

      Timecop.freeze(6.days.ago) do
        FactoryGirl.create(:challenge, :game => game, :challenger => player_1, :challengee => player_2)
      end

      post :expire_pending

      player_1_rating.reload.value.should_not == old_rating_1
      player_2_rating.reload.value.should_not == old_rating_2
    end
  end
end
