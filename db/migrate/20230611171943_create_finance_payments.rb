class CreateFinancePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_payments do |t|
      t.date :date
      t.text :what
      t.float :amount
      t.text :from
      t.text :to
      t.float :remaining
      t.float :rate
      t.integer :dom
      t.integer :inc
      t.text :note

      t.timestamps
    end
  end
end
