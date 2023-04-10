class CreateFinanceCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_categories do |t|
      t.string :ctype
      t.string :category
      t.string :subcategory
      t.string :tax

      t.timestamps
    end
  end
end
