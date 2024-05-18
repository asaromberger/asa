class CreateBridgeTables < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_tables do |t|
      t.string :stype
      t.integer :stable
      t.integer :round
      t.integer :ns
      t.integer :ew
      t.integer :board

      t.timestamps
    end
  end
end
