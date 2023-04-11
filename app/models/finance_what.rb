class FinanceWhat < ApplicationRecord

	belongs_to :finance_category

	has_many :finance_items
	has_many :finance_what_maps

end
