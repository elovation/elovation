class Result < ActiveRecord::Base
  has_many :teams
  belongs_to :game

  validates :game, presence: true
  scope :most_recent_first, :order => "created_at desc"
  scope :for_game, lambda { |game| where(:game_id => game.id) }

  validate do |result|
    if result.winners.empty?
      result.errors.add(:teams, "must have a winner")
    end

    if result.players.size != players.uniq.size
      result.errors.add(:teams, "must have unique players")
    end

    if result.teams.size < result.game.min_number_of_teams
      result.errors.add(:teams, "must have at least #{result.game.min_number_of_teams} teams")
    end

    if result.game.max_number_of_teams && result.teams.size > result.game.max_number_of_teams
      result.errors.add(:teams, "must have at most #{result.game.max_number_of_teams} teams")
    end

    if result.teams.any?{|team| team.players.size < result.game.min_number_of_players_per_team}
      result.errors.add(:teams, "must have at least #{result.game.min_number_of_players_per_team} players per team")
    end

    if result.game.max_number_of_players_per_team && result.teams.any?{|team| team.players.size > result.game.max_number_of_players_per_team}
      result.errors.add(:teams, "must have at most #{result.game.max_number_of_players_per_team} players per team")
    end

    if !result.game.allow_ties && result.teams.map(&:rank).uniq.size != result.teams.size
      result.errors.add(:teams, "game does not allow ties")
    end
  end

  def players
    teams.map(&:players).flatten
  end

  def winners
    teams.select{|team| team.rank == Team::FIRST_PLACE_RANK}.map(&:players).flatten
  end

  def losers
    teams.select{|team| team.rank != Team::FIRST_PLACE_RANK}.map(&:players).flatten
  end

  def as_json(options = {})
    {
      :winner => winners.first.name,
      :loser => losers.first.name,
      :created_at => created_at.utc.to_s
    }
  end

  def most_recent?
    teams.all? do |team|
      team.players.all? do |player|
        player.results.where(:game_id => game.id).order("created_at DESC").first == self
      end
    end
  end

  def self.find_winning_streaks(game)
    recent_losses_sql = select('game_id, loser_id as player_id, max(created_at) as loss_created_at').
                        group('game_id, loser_id').to_sql

    # count wins with created_at date after the most recent loss
    winning_streaks = select('winner_id, count(1) as winning_streak').
                      joins("left join (#{recent_losses_sql}) recent_losses on player_id = winner_id and recent_losses.game_id = results.game_id").
                      where(:game_id => game).
                      where('loss_created_at is null or created_at > loss_created_at').
                      group(:winner_id).
                      having('count(1) >= 3')

    return Hash[ winning_streaks.collect {|i| [i.winner_id.to_i, i.winning_streak.to_i] } ]
  end
end
