class ChangeNsscoreFromBridgeResults < ActiveRecord::Migration[7.0]
  def change
  	change_column :bridge_results, :nspoints, :decimal
  	change_column :bridge_results, :ewpoints, :decimal
  end
end
