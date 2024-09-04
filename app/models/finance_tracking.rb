class FinanceTracking < ApplicationRecord

	belongs_to :finance_investments_account, optional: true
	belongs_to :finance_investments_fund, optional: true

end
