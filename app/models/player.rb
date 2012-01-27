class Player < ActiveRecord::Base
  validates :name, :uniqueness => true
end
