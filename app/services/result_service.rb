class ResultService
  Response = Data.define(:success, :result) do
    def initialize(success:, result: nil) = super
    def success? = success
  end

  def self.create(game, params)
    result = game.results.build

    next_rank = Team::FIRST_PLACE_RANK
    teams = (params[:teams] || {}).values.each.with_object([]) do |team, acc|
      players = Array.wrap(team[:players]).delete_if(&:blank?)
      acc << { rank: next_rank, players: players }

      next_rank = next_rank + 1 if team[:relation] != "ties"
    end

    teams = teams.reverse.drop_while{ |team| team[:players].empty? }.reverse

    teams.each do |team|
      result.teams.build rank: team[:rank], player_ids: team[:players]
    end

    if result.valid?
      Result.transaction do
        result.save!
        game.leaderboard.record(result)

        Response.new(success: true, result: result)
      end
    else
      Response.new(success: false, result: result)
    end
  end

  def self.destroy(result)
    Response.new(success: result.game.leaderboard.retract(result))
  end
end