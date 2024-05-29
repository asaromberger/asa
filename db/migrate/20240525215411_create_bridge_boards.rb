class CreateBridgeBoards < ActiveRecord::Migration[7.0]
  def change
    create_table :bridge_boards do |t|
      t.integer :board
      t.boolean :nsvul
      t.boolean :ewvol

      t.timestamps
    end
  end
end
