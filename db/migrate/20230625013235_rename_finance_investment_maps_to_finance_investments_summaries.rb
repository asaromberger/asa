class RenameFinanceInvestmentMapsToFinanceInvestmentsSummaries < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_summary_types, :finance_investments_summaries
  end
end
