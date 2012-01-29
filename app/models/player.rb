class Player < ActiveRecord::Base
  has_and_belongs_to_many :results

  validates :name, :uniqueness => true, :presence => true
end
