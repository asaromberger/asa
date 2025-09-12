class CreateTrumpsBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :trumps_boards do |t|
      t.integer :trumps_game_id
      t.integer :round
      t.integer :trummps_numberofcards

      t.timestamps
    end
  end
end
