class Finance::Expenses::TransfersController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Transfers'
		# build what_id to what and cat_id tables
		whats = Hash.new
		whatcatids = Hash.new
		FinanceExpensesWhat.all.each do |what|
			whats[what.id] = what.what
			whatcatids[what.id] = what.finance_expenses_category_id
		end
		# build cat_id to ctype, category, subcategory, tax tables
		ctypes = Hash.new
		categories = Hash.new
		subcategories = Hash.new
		taxes = Hash.new
		FinanceExpensesCategory.all.each do |category|
			ctypes[category.id] = category.ctype
			categories[category.id] = category.category
			subcategories[category.id] = category.subcategory
			taxes[category.id] = category.tax
		end
		@transfers = Hash.new
		FinanceExpensesItem.joins(:finance_expenses_what).where("lower(what) LIKE '%transfer%'").order('date').each do |transfer|
			@transfers[transfer.id] = Hash.new
			@transfers[transfer.id]['date'] = transfer.date
			@transfers[transfer.id]['pm'] = transfer.pm
			@transfers[transfer.id]['what'] = whats[transfer.finance_expenses_what_id]
			@transfers[transfer.id]['amount'] = transfer.amount
			@transfers[transfer.id]['type'] = ctypes[whatcatids[transfer.finance_expenses_what_id]]
			@transfers[transfer.id]['category'] = categories[whatcatids[transfer.finance_expenses_what_id]]
			@transfers[transfer.id]['subcategory'] = subcategories[whatcatids[transfer.finance_expenses_what_id]]
		end
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE EXPENSES TRANSFERS"
		end
	end

end
