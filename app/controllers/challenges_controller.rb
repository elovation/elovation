class ChallengesController < ApplicationController
  before_filter :_find_game, :except => :expire_pending

  def create
    @challenge = Challenge.new(params[:challenge])
    @challenge.game = @game

    if @challenge.save
      Notify.challenge_email(request.protocol + request.host_with_port, @challenge).deliver
      redirect_to game_path(@game)
    else
      render :new
    end
  end

  def destroy
    challenge = @game.challenges.find_by_id(params[:id])
    challenge.destroy
    redirect_to game_path(@game)
  end

  def new
    @challenge = Challenge.new
  end

  def expire_pending
    challenges_to_expire = Challenge.active.order(:created_at).select {|c| c.expires_at <= Time.now}

    errors = 0
    challenges_to_expire.each do |challenge|

      response = ResultService.create(
        challenge.game,
        {
          :winner_id => challenge.challenger_id,
          :loser_id  => challenge.challengee_id
        }
      )
      if response.success?
        challenge.result = response.result
        challenge.save
      else
        errors = errors + 1
      end

    end

    error_message = errors > 0 ? " (#{errors} errors" : ""
    render :inline => "#{challenges_to_expire.size} challenges expired#{error_message}"
  end

  def _find_game
    @game = Game.find(params[:game_id])
  end
end
