# frozen_string_literal: true

class Team < ApplicationRecord
  FIRST_PLACE_RANK = 1

  has_many :memberships, dependent: :destroy
  has_many :players, through: :memberships
  belongs_to :result, optional: true

  validates :rank, presence: true

  scope :winners, lambda {
    where(rank: FIRST_PLACE_RANK)
  }

  scope :losers, lambda {
    where.not(rank: FIRST_PLACE_RANK)
  }
end
