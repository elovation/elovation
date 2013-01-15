class ConvertPlayersToTeams < ActiveRecord::Migration
  class Result < ActiveRecord::Base
    has_many :teams
  end

  class Team < ActiveRecord::Base
    belongs_to :result
    has_and_belongs_to_many :players
  end

  def up
    ActiveRecord::Base.connection.transaction do
      Result.all.each do |result|
        result.teams.build rank: 1, player_ids: [result.winner_id]
        result.teams.build rank: 2, player_ids: [result.loser_id]
        result.save!
      end
    end
  end

  def down
  end
end
