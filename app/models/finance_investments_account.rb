class FinanceInvestmentsAccount < ApplicationRecord

	has_many :finance_investments_funds
	has_many :finance_investments_summary_contents
	has_many :finance_trackings

	validates :name, uniqueness: true

end
