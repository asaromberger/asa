class AddFinanceInvestmentsAccountIdToFinanceInvestmentsFunds < ActiveRecord::Migration[7.0]
  def change
    add_column :finance_investments_funds, :finance_investments_account_id, :integer
  end
end
