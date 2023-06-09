class Finance::Expenses::RentalcostsController < ApplicationController

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
		@title = "Rental Costs from #{@fromyear} to #{@toyear}"
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
		# build cat_id to category, subcategory, tax tables
		categories = Hash.new
		subcategories = Hash.new
		taxes = Hash.new
		FinanceExpensesCategory.all.each do |category|
			categories[category.id] = category.category
			subcategories[category.id] = category.subcategory
			taxes[category.id] = category.tax
		end
		# @data[category][subcategory][year]
		@data = Hash.new
		FinanceExpensesItem.joins(:finance_expenses_what => :finance_expenses_category).where("ctype = 'rental' AND EXTRACT(year FROM date) >= ? AND EXTRACT(year FROM date) <= ?", @fromyear, @toyear).each do |item|
			category = categories[whatcatids[item.finance_expenses_what_id]]
			subcategory = subcategories[whatcatids[item.finance_expenses_what_id]]
			if subcategory == 'Security Deposit'
				next
			end
			amount = item.amount
			year = item.date.year
			if item.pm == '-'
				amount = -amount
			end
			# accumulate in cat/subcat/year
			if ! @data[category]
				@data[category] = Hash.new
			end
			if ! @data[category][subcategory]
				@data[category][subcategory] = Hash.new
			end
			if @data[category][subcategory][year]
				@data[category][subcategory][year] = @data[category][subcategory][year] + amount
			else
				@data[category][subcategory][year] = amount
			end
			# accumulate in cat/subcat/total
			if @data[category][subcategory]['total']
				@data[category][subcategory]['total'] = @data[category][subcategory]['total'] + amount
			else
				@data[category][subcategory]['total'] = amount
			end
			if subcategory != 'Upkeep' && subcategory != 'Rent'
				# accumulate in cat totals
				if ! @data[category]['~']
					@data[category]['~'] = Hash.new
				end
				if @data[category]['~'][year]
					@data[category]['~'][year] = @data[category]['~'][year] + amount
				else
					@data[category]['~'][year] = amount
				end
				# accumulate in cat/total
				if @data[category]['~']['total']
					@data[category]['~']['total'] = @data[category]['~']['total'] + amount
				else
					@data[category]['~']['total'] = amount
				end
			end
		end
		# averages
		@data.each do |cat, catdata|
			catdata.each do |subcat, subcatdata|
				@data[cat][subcat]['average'] = @data[cat][subcat]['total'] / @years.count
			end
		end
	end

	def show
		@title = "#{params[:category]}/#{params[:subcategory]}"
		@fromyear = params[:fromyear]
		@toyear = params[:toyear]
		category_id = FinanceExpensesCategory.where("ctype = 'rental' AND category = ? AND subcategory = ?", params[:category], params['subcategory']).pluck('id').first
		what_ids = FinanceExpensesWhat.where("finance_expenses_category_id = ?", category_id).pluck('DISTINCT id')
		@items = FinanceExpensesItem.where("EXTRACT(year FROM date) >= ? AND EXTRAcT(year FROM date) <= ? AND finance_expenses_what_id IN (?)", @fromyear, @toyear, what_ids).order('date')
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to root_url, alert: "Inadequate permissions: FINANCE EXPENSES RENTALCOSTS"
		end
	end

end
