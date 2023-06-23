class FinanceInvestmentsFund < ApplicationRecord

	belongs_to :finance_investments_account

	has_many :finance_investment_maps
	has_many :finance_investments
	has_many :finance_investments_funds

end
