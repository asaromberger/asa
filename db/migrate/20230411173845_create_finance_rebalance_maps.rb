class CreateFinanceRebalanceMaps < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_rebalance_maps do |t|
      t.integer :finance_rebalance_type_id
      t.integer :finance_account_id
      t.decimal :target

      t.timestamps
    end
  end
end
