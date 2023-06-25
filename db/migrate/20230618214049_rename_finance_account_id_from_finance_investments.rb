class RenameFinanceAccountIdFromFinanceInvestments < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_investments, :finance_account_id, :finance_investments_fund_id
  end
end
