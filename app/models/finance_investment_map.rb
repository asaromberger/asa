class FinanceInvestmentMap < ApplicationRecord

	belongs_to :finance_account
	belongs_to :finance_summary_type

end
