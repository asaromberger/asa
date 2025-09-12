class CreateTrumpsPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :trumps_players do |t|
      t.integer :trumps_game_id
      t.integer :trumps_name_id

      t.timestamps
    end
  end
end
