class RenameFinanceAccountmapsToFinanceExpensesAccountmaps < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_accountmaps, :finance_expenses_accountmaps
  end
end
