class Game < ActiveRecord::Base
  has_many :ratings
  has_many :results

  validates :name, :presence => true

  def recent_results
    results.order("created_at DESC").limit(5)
  end

  def top_ratings
    ratings.order("value DESC").limit(5)
  end
end
