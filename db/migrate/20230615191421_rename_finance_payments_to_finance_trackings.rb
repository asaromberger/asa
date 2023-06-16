class RenameFinancePaymentsToFinanceTrackings < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_payments, :finance_trackings
  end
end
