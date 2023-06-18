class RenameFinanceInputsToFinanceExpensesInputs < ActiveRecord::Migration[7.0]
  def change
  	rename_table :finance_inputs, :finance_expenses_inputs
  end
end
