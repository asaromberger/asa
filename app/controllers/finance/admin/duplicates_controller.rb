class Finance::Admin::DuplicatesController < ApplicationController

	before_action :require_signed_in
	before_action :require_finance_admin

	def index
		@title = "Duplicates"

		@duplicates = Hash.new

		@duplicates['Expenses Items'] = []
		items = Hash.new
		FinanceExpensesItem.all.order('date').each do |item|
			if ! items[item.date]
				items[item.date] = Hash.new
			end
			if ! items[item.date][item.pm]
				items[item.date][item.pm] = Hash.new
			end
			if ! items[item.date][item.pm][item.finance_expenses_what_id]
				items[item.date][item.pm][item.finance_expenses_what_id] = Hash.new
			end
			if ! items[item.date][item.pm][item.finance_expenses_what_id][item.amount]
				items[item.date][item.pm][item.finance_expenses_what_id][item.amount] = item
			else
				@duplicates['Expenses Items'].push("#{item.date} #{item.finance_expenses_what.what} #{item.amount}")
			end
		end

	end

	def require_finance_admin
		unless current_user_role('finance_admin')
			redirect_to root_url, alert: "inadequate permissions: FINANCE ADMIN"
		end
	end

end
