class RenameFinanceCategoriesToFinanceExpensesCategories < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_categories, :finance_expenses_categories
  end
end
