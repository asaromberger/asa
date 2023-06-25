class RenameFinanceInvestmentMapsToFinanceInvestmentsSummaryContents < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_investment_maps, :finance_investments_summary_contents
  end
end
