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
        game.rate!(result.teams)

        result.save!

        Response.new(success: true, result: result)
      end
    else
      Response.new(success: false, result: result)
    end
  end

  def self.destroy(result)
    return Response.new(success: false) unless result.most_recent?

    Result.transaction do
      result.players.each do |player|
        player.rewind_rating!(result.game)
      end

      result.destroy

      Response.new(success: true)
    end
  end
end