class CreateFinanceItems < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_items do |t|
      t.date :date
      t.string :pm
      t.string :checkno
      t.integer :finance_what_id
      t.decimal :amount

      t.timestamps
    end
  end
end
