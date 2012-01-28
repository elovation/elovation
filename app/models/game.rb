class Game < ActiveRecord::Base
  validates :description, :presence => true
  validates :name, :presence => true
end
