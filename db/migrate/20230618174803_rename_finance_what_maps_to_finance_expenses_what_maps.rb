class RenameFinanceWhatMapsToFinanceExpensesWhatMaps < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_what_maps, :finance_expenses_what_maps
  end
end
