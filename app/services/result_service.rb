# frozen_string_literal: true

class ResultService
  Response = Data.define(:success, :result) do
    def initialize(success:, result: nil) = super
    def success? = success
  end

  def self.create(game, params)
    result = game.results.build
    placings(params[:teams]).each do |rank, player_ids|
      result.teams.build(rank: rank, player_ids: player_ids)
    end
    return Response.new(success: false, result: result) unless result.valid?

    Result.transaction do
      result.save!
      game.leaderboard.record(result)
    end
    Response.new(success: true, result: result)
  end

  def self.destroy(result)
    Response.new(success: result.game.leaderboard.retract(result))
  end

  # The form's teams, in order, as [rank, player_ids] pairs. Each team ranks
  # below the one before it unless that one "ties" with it. Trailing teams
  # with no players are dropped.
  def self.placings(teams)
    rank = Team::FIRST_PLACE_RANK
    placings = (teams || {}).values.map do |team|
      placing = [rank, Array.wrap(team[:players]).compact_blank]
      rank += 1 if team[:relation] != 'ties'
      placing
    end
    placings.reverse.drop_while { |_, player_ids| player_ids.empty? }.reverse
  end
  private_class_method :placings
end
