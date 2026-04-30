class Category < ApplicationRecord
  belongs_to :game
  has_many :runs, dependent: :destroy
  
  def leaderboard
    Run.leaderboard_for(self)
  end

end
