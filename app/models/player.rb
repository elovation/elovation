class Player < ApplicationRecord
  has_many :teams, through: :memberships
end
