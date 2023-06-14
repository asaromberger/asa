class RemoveDomFromFinancePayments < ActiveRecord::Migration[7.0]
  def change
    remove_column :finance_payments, :dom, :integer
  end
end
