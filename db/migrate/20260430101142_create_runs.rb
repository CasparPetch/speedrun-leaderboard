class CreateRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :runs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :time_ms
      t.integer :position
      t.integer :status
      t.string :video_url

      t.timestamps
    end
  end
end
