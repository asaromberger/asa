class DropOldFinanceRebalanceTables < ActiveRecord::Migration[7.0]
  def change
  	drop_table :finance_rebalance_maps
	drop_table :finance_rebalance_types
  end
end
