class FinanceAccount < ApplicationRecord

	has_many :finance_investment_maps
	has_many :finance_investments

end
