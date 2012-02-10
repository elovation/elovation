class Player < ActiveRecord::Base
  has_many :ratings, :order => "value DESC", :dependent => :destroy do
    def find_or_create(game)
      where(:game_id => game.id).first || create(:game => game, :value => Rating::DefaultValue, :pro => false)
    end
  end

  has_and_belongs_to_many :results

  before_destroy do
    results.each { |result| result.destroy }
  end

  validates :name, :uniqueness => true, :presence => true

  def recent_results
    results.order("created_at DESC").limit(5)
  end
end
