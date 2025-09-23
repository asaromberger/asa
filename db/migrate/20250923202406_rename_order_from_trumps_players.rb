class RenameOrderFromTrumpsPlayers < ActiveRecord::Migration[7.0]
  def change
  	rename_column :trumps_players, :order, :porder
  end
end
