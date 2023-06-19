class RenameAccountFromFinanceInvestmentsFunds < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_investments_funds, :account, :fund
  end
end
