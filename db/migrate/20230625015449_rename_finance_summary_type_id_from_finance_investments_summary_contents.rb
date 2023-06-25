class RenameFinanceSummaryTypeIdFromFinanceInvestmentsSummaryContents < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_investments_summary_contents, :finance_summary_type_id, :finance_investments_summary_id
  end
end
