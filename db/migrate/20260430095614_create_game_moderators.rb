class CreateGameModerators < ActiveRecord::Migration[8.1]
  def change
    create_table :game_moderators do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      add_index :game_moderators, [:user_id, :game_id], unique: true

      t.timestamps
    end
  end
end
