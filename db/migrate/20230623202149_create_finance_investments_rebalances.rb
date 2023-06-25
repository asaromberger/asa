class CreateFinanceInvestmentsRebalances < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_investments_rebalances do |t|
      t.integer :finance_investments_fund_id
      t.decimal :target

      t.timestamps
    end
  end
end
