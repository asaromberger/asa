class CreateBridgePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_players do |t|
      t.string :name

      t.timestamps
    end
  end
end
