class Team < ApplicationRecord
  belongs_to :result
  has_many :players, through: :memberships
end
