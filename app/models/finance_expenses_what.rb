class FinanceExpensesWhat < ApplicationRecord

	belongs_to :finance_expenses_category

	has_many :finance_expenses_items
	has_many :finance_expenses_what_maps

	validates :what, uniqueness: true

end
