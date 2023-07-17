class FinanceInvestmentsAccount < ApplicationRecord

	has_many :finance_investments_funds
	has_many :finance_investments_summary_contents

	validates :name, uniqueness: true

end
