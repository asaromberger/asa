class AddNumberOfPlayersToBridgeBbos < ActiveRecord::Migration[7.0]
  def change
    add_column :bridge_bbos, :no_players, :integer
  end
end
