class CreateFinanceInvestments < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_investments do |t|
      t.integer :finance_account_id
      t.date :date
      t.decimal :value
      t.decimal :shares
      t.decimal :pershare
      t.decimal :guaranteed

      t.timestamps
    end
  end
end
