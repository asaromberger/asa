class CreateFinanceAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_accounts do |t|
      t.string :account
      t.string :atype
      t.boolean :closed

      t.timestamps
    end
  end
end
