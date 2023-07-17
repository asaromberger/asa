class FinanceInvestmentsSummary < ApplicationRecord

	has_many :finance_investments_summary_contents

	validates :stype, uniqueness: true

end
