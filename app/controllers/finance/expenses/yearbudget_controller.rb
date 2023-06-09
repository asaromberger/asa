class Finance::Expenses::YearbudgetController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		if params[:year]
			@year = params[:year]
		else
			@year = Time.now.year
		end
		@title = "#{@year} Budget"
		@years = []
		FinanceExpensesItem.all.pluck(Arel.sql("DISTINCT EXTRACT(year FROM date)")).each do |year|
			@years.push(year.to_i)
		end
		@years = @years.sort.reverse
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
		# @data[ctype][category][subcategory][month]
		@data = Hash.new
		@ctotals = Hash.new
		FinanceExpensesItem.where("EXTRACT(year FROM date) = ?", @year).each do |item|
			ctype = ctypes[whatcatids[item.finance_expenses_what_id]]
			category = categories[whatcatids[item.finance_expenses_what_id]]
			subcategory = subcategories[whatcatids[item.finance_expenses_what_id]]
			amount = item.amount
			month = item.date.month
			if item.pm == '-'
				amount = -amount
			end
			# accumulate in cat/subcat/month
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
			if @data[ctype][category][subcategory][month]
				@data[ctype][category][subcategory][month] = @data[ctype][category][subcategory][month] + amount
			else
				@data[ctype][category][subcategory][month] = amount
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
			if @data[ctype][category]['~'][month]
				@data[ctype][category]['~'][month] = @data[ctype][category]['~'][month] + amount
			else
				@data[ctype][category]['~'][month] = amount
			end
			# accumulate in cat/total
			if @data[ctype][category]['~']['total']
				@data[ctype][category]['~']['total'] = @data[ctype][category]['~']['total'] + amount
			else
				@data[ctype][category]['~']['total'] = amount
			end
			# accumulate in ctotals
			if @ctotals[ctype][month]
				@ctotals[ctype][month] = @ctotals[ctype][month] + amount
			else
				@ctotals[ctype][month] = amount
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
					@data[ctype][cat][subcat]['average'] = @data[ctype][cat][subcat]['total'] / 12
				end
			end
		end
		@ctotals.each do |ctype, ctypedata|
			@ctotals[ctype]['average'] = @ctotals[ctype]['total'] / 12
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
			redirect_to users_path, alert: "Inadequate permissions: FINANCE EXPENSES YEARBUDGET"
		end
	end

end
