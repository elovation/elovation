class Game < ActiveRecord::Base
  validates :name, :presence => true
end
