class Result < ActiveRecord::Base
  has_many :teams
  belongs_to :game

  scope :most_recent_first, :order => "created_at desc"
  scope :for_game, lambda { |game| where(:game_id => game.id) }

  validate do |result|
    if result.winners.empty?
      errors.add(:teams, "must have a winner")
    end

    if result.players.size < 2
      errors.add(:teams, "must have two teams")
    end

    player_ids = result.players.map(&:id)
    if player_ids.size != player_ids.uniq.size
      errors.add(:teams, "must have unique players")
    end
  end

  def players
    teams.map(&:players).flatten
  end

  def winners
    teams.detect{|team| team.rank == Team::FIRST_PLACE_RANK}.try(:players) || []
  end

  def losers
    teams.detect{|team| team.rank != Team::FIRST_PLACE_RANK}.try(:players) || []
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
end
