class FinanceInvestmentsFund < ApplicationRecord

	belongs_to :finance_investments_account

	has_many :finance_investments_investments
	has_many :finance_investments_rebalances
	has_many :finance_trackings

end
