class RenameFinanceAccountsToFinanceInvestmentsFunds < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_accounts, :finance_investments_funds
  end
end
