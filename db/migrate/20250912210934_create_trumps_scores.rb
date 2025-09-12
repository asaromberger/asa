class CreateTrumpsScores < ActiveRecord::Migration[7.0]
  def change
    create_table :trumps_scores do |t|
      t.integer :trumps_board_id
      t.integer :trumps_player_id
      t.integer :bid
      t.integer :made

      t.timestamps
    end
  end
end
