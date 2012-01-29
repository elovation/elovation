class Game < ActiveRecord::Base
  has_many :results

  validates :name, :presence => true
end
