class RenameFinanceInvestmentsFundIdFromFinanceInvestmentsSummaryContents < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_investments_summary_contents, :finance_investments_fund_id, :finance_investments_account_id
  end
end
