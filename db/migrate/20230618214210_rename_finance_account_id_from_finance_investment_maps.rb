class RenameFinanceAccountIdFromFinanceInvestmentMaps < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_investment_maps, :finance_account_id, :finance_investments_fund_id
  end
end
