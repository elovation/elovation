class Player < ActiveRecord::Base
  has_many :ratings, :order => "value DESC", :dependent => :destroy do
    def find_or_create(game)
      where(:game_id => game.id).first || create({game: game, pro: false}.merge(game.rater.default_attributes))
    end
  end

  has_and_belongs_to_many :teams

  has_many :results, through: :teams do
    def against(opponent)
      joins("INNER JOIN teams AS other_teams ON results.id = other_teams.result_id")
        .joins("INNER JOIN players_teams AS other_players_teams ON other_teams.id = other_players_teams.team_id")
        .where("other_players_teams.player_id = ?", opponent)
    end

    def losses
      where("teams.rank > ?", Team::FIRST_PLACE_RANK)
    end

    def wins
      where(:teams => {:rank => Team::FIRST_PLACE_RANK})
    end
  end

  before_destroy do
    results.each { |result| result.destroy }
  end

  validates :name, :uniqueness => true, :presence => true
  validates :email, :format => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, :allow_blank => true

  def as_json
    {
      :name => name,
      :email => email
    }
  end

  def recent_results
    results.order("created_at DESC").limit(5)
  end

  def rewind_rating!(game)
    rating = ratings.where(:game_id => game.id).first
    rating.rewind!
  end
end
