class CreateFinanceWhats < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_whats do |t|
      t.string :what
      t.integer :finance_category_id

      t.timestamps
    end
  end
end
