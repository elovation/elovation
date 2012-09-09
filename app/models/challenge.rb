class Challenge < ActiveRecord::Base
  belongs_to :challenger, :class_name => "Player"
  belongs_to :challengee, :class_name => "Player"
  belongs_to :game
  belongs_to :result

  scope :active, where(:result_id => nil)
  scope :inactive, where('result_id is not null')
  scope :for_game, lambda { |game| where(:game_id => game.id) }

  validate :check_challenger_is_not_challengee
  validate :check_challenger_is_not_already_in_a_challenge
  validates_presence_of :challenger
  validates_presence_of :challengee
  validates_presence_of :game

  def check_challenger_is_not_challengee
    if challenger == challengee and not challenger.nil?
      errors.add(:challengee, "Challenger and challengee can't be the same player")
    end
  end

  def check_challenger_is_not_already_in_a_challenge
    return if game.nil? or challenger.nil?

    # when testing this validation, it is important that this check does not find
    # itself and fail validation.  however, in practice, this is only run before id
    # has been set and comparisons with null always return false
    id_or_zero = id || 0

    if Challenge.active.for_game(game).where('challenger_id = ? and id != ?', challenger.id, id_or_zero).exists?
      errors.add(:challenger, "#{challenger.name} is already in a challenge")
    end
  end

  def expires_at
    return created_at + self.class.expiration_threshold
  end

  def self.expiration_threshold
    return 5.days
  end

  def as_json(options = {})
    {
      :challenger => challenger.name,
      :challengee => challengee.name,
      :expires_at => expires_at.utc.to_s,
    }
  end

  def self.find_active_challenges_for_result(result)
    expected_ids = [result.winner_id, result.loser_id].sort

    return self.active.for_game(result.game).find_all do |challenge|
      [challenge.challenger_id, challenge.challengee_id].sort == expected_ids
    end
  end
end
