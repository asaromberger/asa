class RenameFinanceCategoryIdFromFinanceWhats < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_whats, :finance_category_id, :finance_expenses_catetory_id
  end
end
