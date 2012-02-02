class Player < ActiveRecord::Base
  has_and_belongs_to_many :results
  has_many :ratings, :order => "value DESC"

  validates :name, :uniqueness => true, :presence => true

  def recent_results
    results.order("created_at DESC").limit(5)
  end
end
