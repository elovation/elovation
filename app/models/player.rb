class Player < ActiveRecord::Base
  has_many :ratings, :order => "value DESC", :dependent => :destroy
  has_and_belongs_to_many :results

  before_destroy do
    results.each { |result| result.destroy }
  end

  validates :name, :uniqueness => true, :presence => true

  def recent_results
    results.order("created_at DESC").limit(5)
  end
end
