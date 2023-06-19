class FinanceInvestmentMap < ApplicationRecord

	belongs_to :finance_investments_fund
	belongs_to :finance_summary_type

end
