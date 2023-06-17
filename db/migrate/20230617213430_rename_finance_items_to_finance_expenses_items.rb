class RenameFinanceItemsToFinanceExpensesItems < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_items, :finance_expenses_items
  end
end
