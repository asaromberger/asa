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
			balance = 0
			if ! @months[date]
				@months[date] = Hash.new
				@months[date]['payment'] = 0
				@months[date]['rent'] = 0
				@months[date]['fee'] = 0
				@months[date]['onboard'] = 0
				@months[date]['percent'] = 0
				@months[date]['distribution'] = 0
				@months[date]['balance'] = 0
			end
			if subcat.match("^Property Management Deposit$")
				@months[date]['payment'] += item.amount
			elsif subcat.match("^Rent - Property Management$")
				@months[date]['rent'] += item.amount
			elsif subcat.match("^Property Management Fee$")
				@months[date]['fee'] += item.amount
			elsif subcat.match("^Property Management Onboard$")
				@months[date]['onboard'] += item.amount
			elsif subcat.match("^Property Management Transfer$")
				@months[date]['distribution'] += item.amount
			else
				@unknowns.push("#{item.date} #{item.finance_expenses_what.what}")
			end
		end
		balance = 0
		@months.each do |date, values|
			if values['rent'] > 0
				values['percent'] = values['fee'] / values['rent'] * 100
			else
				values['percent'] = 0
			end
			balance = balance + values['payment'] + values['rent'] - values['fee'] - values['onboard'] - values['distribution']
			values['balance'] = balance
		end
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to root_url, alert: "Inadequate permissions: FINANCE EXPENSES ACCOUNTMAPS"
		end
	end

end
