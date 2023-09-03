class Player < ApplicationRecord
  has_many :teams, through: :memberships

  validates :name, uniqueness: true, presence: true
  validates :email, allow_blank: true, format: { with: /@/, message: "expected an @ character" }
end
