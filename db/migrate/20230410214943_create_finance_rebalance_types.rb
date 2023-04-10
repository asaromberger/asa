class CreateFinanceRebalanceTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_rebalance_types do |t|
      t.string :rtype

      t.timestamps
    end
  end
end
