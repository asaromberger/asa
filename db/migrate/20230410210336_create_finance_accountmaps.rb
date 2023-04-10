class CreateFinanceAccountmaps < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_accountmaps do |t|
      t.string :account
      t.string :ctype

      t.timestamps
    end
  end
end
