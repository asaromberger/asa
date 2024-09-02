class AddFinanceInvestmentsFundIdToFinanceTrackings < ActiveRecord::Migration[7.0]
  def change
    add_column :finance_trackings, :finance_investments_fund_id, :integer
  end
end
