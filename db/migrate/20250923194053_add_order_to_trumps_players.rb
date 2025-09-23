class AddOrderToTrumpsPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :trumps_players, :order, :integer
  end
end
