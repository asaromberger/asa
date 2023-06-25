class CreateFinanceInvestmentsAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :finance_investments_accounts do |t|
      t.text :name

      t.timestamps
    end
  end
end
