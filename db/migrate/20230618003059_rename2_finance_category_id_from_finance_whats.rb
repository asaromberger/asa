class Rename2FinanceCategoryIdFromFinanceWhats < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_whats, :finance_expenses_catetory_id, :finance_expenses_category_id
  end
end
