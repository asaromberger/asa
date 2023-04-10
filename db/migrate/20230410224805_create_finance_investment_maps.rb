class CreateFinanceInvestmentMaps < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_investment_maps do |t|
      t.integer :finance_account_id
      t.integer :finance_summary_type_id

      t.timestamps
    end
  end
end
