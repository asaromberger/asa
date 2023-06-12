class AddTypeToFinancePayments < ActiveRecord::Migration[7.0]
  def change
    add_column :finance_payments, :type, :string
  end
end
