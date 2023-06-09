class Finance::Expenses::RunningbudgetController < ApplicationController

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
		@title = "Running Budget from #{@fromyear} to #{@toyear}"
		@pickyears = []
		FinanceExpensesItem.all.pluck(Arel.sql("DISTINCT EXTRACT(year FROM date)")).each do |year|
			@pickyears.push(year.to_i)
		end
		@pickyears = @pickyears.sort
		@years = []
		(@fromyear..@toyear).each do |year|
			@years.push(year.to_i)
		end
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
		# @data[ctype][category][subcategory][year]
		@data = Hash.new
		@ctotals = Hash.new
		FinanceExpensesItem.where("EXTRACT(year FROM date) >= ? AND EXTRACT(year FROM date) <= ?", @fromyear, @toyear).each do |item|
			ctype = ctypes[whatcatids[item.finance_expenses_what_id]]
			category = categories[whatcatids[item.finance_expenses_what_id]]
			subcategory = subcategories[whatcatids[item.finance_expenses_what_id]]
			amount = item.amount
			year = item.date.year
			if item.pm == '-'
				amount = -amount
			end
			# accumulate in cat/subcat/year
			if ! @data[ctype]
				@data[ctype] = Hash.new
			end
			if ! @ctotals[ctype]
				@ctotals[ctype] = Hash.new
			end
			if ! @data[ctype][category]
				@data[ctype][category] = Hash.new
			end
			if ! @data[ctype][category][subcategory]
				@data[ctype][category][subcategory] = Hash.new
			end
			if @data[ctype][category][subcategory][year]
				@data[ctype][category][subcategory][year] = @data[ctype][category][subcategory][year] + amount
			else
				@data[ctype][category][subcategory][year] = amount
			end
			# accumulate in cat/subcat/total
			if @data[ctype][category][subcategory]['total']
				@data[ctype][category][subcategory]['total'] = @data[ctype][category][subcategory]['total'] + amount
			else
				@data[ctype][category][subcategory]['total'] = amount
			end
			# accumulate in cat totals
			if ! @data[ctype][category]['~']
				@data[ctype][category]['~'] = Hash.new
			end
			if @data[ctype][category]['~'][year]
				@data[ctype][category]['~'][year] = @data[ctype][category]['~'][year] + amount
			else
				@data[ctype][category]['~'][year] = amount
			end
			# accumulate in cat/total
			if @data[ctype][category]['~']['total']
				@data[ctype][category]['~']['total'] = @data[ctype][category]['~']['total'] + amount
			else
				@data[ctype][category]['~']['total'] = amount
			end
			# accumulate in ctotals
			if @ctotals[ctype][year]
				@ctotals[ctype][year] = @ctotals[ctype][year] + amount
			else
				@ctotals[ctype][year] = amount
			end
			if @ctotals[ctype]['total']
				@ctotals[ctype]['total'] = @ctotals[ctype]['total'] + amount
			else
				@ctotals[ctype]['total'] = amount
			end
		end
		# averages
		@data.each do |ctype, ctypedata|
			ctypedata.each do |cat, catdata|
				catdata.each do |subcat, subcatdata|
					@data[ctype][cat][subcat]['average'] = @data[ctype][cat][subcat]['total'] / @years.count
				end
			end
		end
		@ctotals.each do |ctype, ctypedata|
			@ctotals[ctype]['average'] = @ctotals[ctype]['total'] / @years.count
		end
	end

	def show
		@title = 'Items'
		@fromyear = params[:fromyear]
		@toyear = params[:toyear]
		@type = params[:type]
		@cat = params[:cat]
		@subcat = params[:subcat]
		category_ids = FinanceExpensesCategory.where("ctype = ? AND category = ? AND subcategory = ?", @type, @cat, @subcat).pluck('id')
		@whats = Hash.new
		what_ids = []
		FinanceExpensesWhat.where("finance_expenses_category_id IN (?)", category_ids).each do |what|
			what_ids.push(what.id)
			@whats[what.id] = what.what
		end
		@items = FinanceExpensesItem.where("EXTRACT(year FROM date) >= ? AND EXTRAcT(year FROM date) <= ? AND finance_expenses_what_id IN (?)", @fromyear, @toyear, what_ids).order('date')
		render 'finance/expenses/runningbudget/show'
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE EXPENSES RUNNINGBUDGET"
		end
	end

end
