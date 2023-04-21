class FinanceRebalanceMap < ApplicationRecord

	belongs_to :finance_rebalance_type
	belongs_to :finance_account

end
