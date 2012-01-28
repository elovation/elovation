require "spec_helper"

describe GamesController do
  describe "new" do
    it "exposes a new game" do
      get :new

      assigns(:game).should_not be_nil
    end
  end

  describe "edit" do
    it "exposes the game for editing" do
      game = FactoryGirl.create(:game)

      get :edit, :id => game

      assigns(:game).should == game
    end
  end

  describe "create" do
    context "with valid params" do
      it "creates a game" do
        post :create, :game => {:name => "Go"}

        Game.where(:name => "Go").first.should_not be_nil
      end

      it "redirects to the game's show page" do
        post :create, :game => {:name => "Go"}

        game = Game.where(:name => "Go").first

        response.should redirect_to(game_path(game))
      end
    end

    context "with invalid params" do
      it "renders new given invalid params" do
        post :create, :game => {:name => nil}

        response.should render_template(:new)
      end
    end
  end

  describe "update" do
    context "with valid params" do
      it "redirects to the game's show page" do
        game = FactoryGirl.create(:game, :name => "First name")

        put :update, :id => game, :game => {:name => "Second name"}

        response.should redirect_to(game_path(game))
      end

      it "updates the game with the provided attributes" do
        game = FactoryGirl.create(:game, :name => "First name")

        put :update, :id => game, :game => {:name => "Second name"}

        game.reload.name.should == "Second name"
      end
    end

    context "with invalid params" do
      it "renders the edit page" do
        game = FactoryGirl.create(:game, :name => "First name")

        put :update, :id => game, :game => {:name => nil}

        response.should render_template(:edit)
      end
    end
  end

  describe "destroy" do
    it "redirects to the dashboard path" do
      game = FactoryGirl.create(:game)

      delete :destroy, :id => game

      response.should redirect_to(dashboard_path)
    end

    it "deletes the given game" do
      game = FactoryGirl.create(:game)

      delete :destroy, :id => game

      Game.find_by_id(game.id).should be_nil
    end
  end

  describe "show" do
    it "exposes the game" do
      game = FactoryGirl.create(:game)

      get :show, :id => game

      assigns(:game).should == game
    end
  end
end
