class RenameFinanceWhatsToFinanceExpensesWhats < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_whats, :finance_expenses_whats
  end
end
