class Flair < ActiveRecord::Base
  has_many :players

  validates :name, uniqueness: true, presence: true

  has_attached_file :avatar, :styles => { :medium => "80x80>", :thumb => "24x24>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
end
