class CreateBridgeScores < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_scores do |t|
      t.date :date
      t.integer :player_id
      t.float :score

      t.timestamps
    end
  end
end
