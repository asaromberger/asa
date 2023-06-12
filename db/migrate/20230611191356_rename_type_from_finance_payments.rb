class RenameTypeFromFinancePayments < ActiveRecord::Migration[7.0]
  def change
  	rename_column :finance_payments, :type, :ptype
  end
end
