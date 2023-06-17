class Finance::Expenses::DonationsController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		if params[:fromyear]
			@fromyear = params[:fromyear]
		else
			@fromyear = Time.now.year - 10
		end
		if params[:toyear]
			@toyear = params[:toyear]
		else
			@toyear = FinanceExpensesItem.all.order('date DESC').first.date.year
		end
		@title = "Donations from #{@fromyear} to #{@toyear}"
		@pickyears = []
		FinanceExpensesItem.all.pluck(Arel.sql("DISTINCT EXTRACT(year FROM date)")).each do |year|
			@pickyears.push(year.to_i)
		end
		@pickyears = @pickyears.sort
		@years = []
		(@fromyear..@toyear).each do |year|
			@years.push(year.to_i)
		end
		# find donations categories
		donationcatids = FinanceCategory.where("tax = 'Donations'").pluck('DISTINCT id')
		# find donations
		@donations = Hash.new
		whatids = []
		FinanceWhat.where("finance_category_id IN (?)", donationcatids).order('what').each do |what|
			whatids.push(what.id)
			@donations[what.id] = Hash.new
			@donations[what.id]['name'] = what.what
			@years.each do |year|
				@donations[what.id][year] = 0
			end
			@donations[what.id]['total'] = 0
		end
		# accumulate donations
		FinanceExpensesItem.where("finance_what_id IN (?) AND EXTRACT(year FROM date) >= ? AND EXTRACT(year FROM date) <= ?", whatids, @fromyear, @toyear).each do |item|
			@donations[item.finance_what_id][item.date.year] = @donations[item.finance_what_id][item.date.year] + item.amount
			@donations[item.finance_what_id]['total'] = @donations[item.finance_what_id]['total'] + item.amount
		end
		@donations.each do |id, values|
			if values['total'] == 0
				@donations.delete(id)
			end
		end
	end

	def show
		what = FinanceWhat.find(params[:id])
		@title = "Donations to #{what.what}"
		@items = FinanceExpensesItem.where("finance_what_id = ?", params[:id]).order('date')
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to root_url, alert: "Inadequate permissions: FINANCE EXPENSES DONATIONS"
		end
	end

end
