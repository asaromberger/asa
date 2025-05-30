class Finance::Expenses::PropertyManagementController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Property Management Details'
		pm_ids = FinanceExpensesCategory.where("lower(subcategory) LIKE '%property management%'").pluck('id')
		what_ids = FinanceExpensesWhat.where("finance_expenses_category_id IN (?)", pm_ids).pluck('id')
		@items = FinanceExpensesItem.where("finance_expenses_what_id IN (?)", what_ids).order('date')
	end

	def show
		@title = 'Property Management Summary'
		cattosubcat = Hash.new
		pm_ids = []
		FinanceExpensesCategory.where("lower(subcategory) LIKE '%property management%'").each do |category|
			pm_ids.push(category.id)
			cattosubcat[category.id] = category.subcategory
		end
		what_ids = []
		whattosubcat = Hash.new
		FinanceExpensesWhat.where("finance_expenses_category_id IN (?)", pm_ids).each do |what|
			what_ids.push(what.id)
			whattosubcat[what.id] = cattosubcat[what.finance_expenses_category_id]
		end
		@months = Hash.new
		@unknowns = []
		FinanceExpensesItem.where("finance_expenses_what_id IN (?)", what_ids).order('date').each do |item|
			date = "#{item.date.year}-#{item.date.month}"
			subcat = whattosubcat[item.finance_expenses_what_id]
			if ! @months[date]
				@months[date] = Hash.new
				@months[date]['income'] = 0
				@months[date]['expense'] = 0
				@months[date]['distribution'] = 0
			end
			if subcat.match("^Property Management Deposit$")
				@months[date]['income'] += item.amount
			elsif subcat.match("^Property Management Fee$")
				@months[date]['expense'] += item.amount
			elsif subcat.match("^Property Management Transfer$")
				@months[date]['distribution'] += item.amount
			elsif subcat.match("^Rent - Property Management$")
				@months[date]['income'] += item.amount
			else
				@unknowns.push("#{item.date} #{item.finance_expenses_what.what}")
			end
		end
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to root_url, alert: "Inadequate permissions: FINANCE EXPENSES ACCOUNTMAPS"
		end
	end

end
