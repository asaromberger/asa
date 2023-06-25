class RenameFinanceInvestmentsToFinanceInvestmentsInvestments < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_investments, :finance_investments_investments
  end
end
