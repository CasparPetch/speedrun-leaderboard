class Category < ApplicationRecord
  belongs_to :game
  has_many :runs, dependent: :destroy
end
