class RenameFinanceWhatIdFromFinanceExpensesWhatMaps < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_expenses_what_maps, :finance_what_id, :finance_expenses_what_id
  end
end
