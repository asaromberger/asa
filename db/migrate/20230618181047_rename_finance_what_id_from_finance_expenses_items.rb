class RenameFinanceWhatIdFromFinanceExpensesItems < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_expenses_items, :finance_what_id, :finance_expenses_what_id
  end
end
