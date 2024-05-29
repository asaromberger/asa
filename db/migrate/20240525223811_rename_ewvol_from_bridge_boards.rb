class RenameEwvolFromBridgeBoards < ActiveRecord::Migration[7.0]
  def change
  	rename_column :bridge_boards, :ewvol, :ewvul
  end
end
