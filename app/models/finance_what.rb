class FinanceWhat < ApplicationRecord

	belongs_to :finance_category

	has_many :finance_items

end
