class Game < ApplicationRecord
    has_many :categories, dependent: :destroy
    has_many :game_moderators, dependent: :destroy
    has_many :moderators, through: :game_moderators, source: :user

end
