class User < ApplicationRecord
    
  has_many :game_moderators, dependent: :destroy
  has_many :moderated_games, through: :game_moderators, source: :game
  has_many :runs, dependent: :destroy

end
