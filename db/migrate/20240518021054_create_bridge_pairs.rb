class CreateBridgePairs < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_pairs do |t|
      t.date :date
      t.integer :pair
      t.integer :player1_id
      t.integer :player2_id

      t.timestamps
    end
  end
end
