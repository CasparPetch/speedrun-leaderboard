class AddUniqueIndexToGameModerators < ActiveRecord::Migration[8.1]
  def change
    add_index :game_moderators, [:user_id, :game_id], unique: true
  end
end
