class CreateBridgeResults < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_results do |t|
      t.date :date
      t.integer :board
      t.string :contract
      t.string :by
      t.integer :result
      t.integer :ns
      t.integer :nsscore
      t.integer :nspoints
      t.integer :ew
      t.integer :ewscore
      t.integer :ewpoints

      t.timestamps
    end
  end
end
