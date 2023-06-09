class Finance::Expenses::TaxesController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		if params[:year]
			@year = params[:year]
		else
			@year = Time.now.year
		end
		@title = "#{@year} Taxes"
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
		# tax category ids
		taxcategoryids = FinanceExpensesCategory.where("(tax IS NOT NULL AND tax != '') OR ctype = 'rental'").pluck('DISTINCT id')
		# @data[ctype][category][subcategory][tax]
		@data = Hash.new
		FinanceExpensesItem.joins(:finance_expenses_what).where("EXTRACT(year FROM date) = ? AND finance_expenses_category_id in (?)", @year, taxcategoryids).each do |item|
			ctype = ctypes[whatcatids[item.finance_expenses_what_id]]
			category = categories[whatcatids[item.finance_expenses_what_id]]
			subcategory = subcategories[whatcatids[item.finance_expenses_what_id]]
			tax = taxes[whatcatids[item.finance_expenses_what_id]]
			amount = item.amount
			if item.pm == '-'
				amount = -amount
			end
			# accumulate in cat/subcat/tax
			if ! @data[ctype]
				@data[ctype] = Hash.new
			end
			if ! @data[ctype][category]
				@data[ctype][category] = Hash.new
			end
			if ! @data[ctype][category][subcategory]
				@data[ctype][category][subcategory] = Hash.new
			end
			if @data[ctype][category][subcategory][tax]
				@data[ctype][category][subcategory][tax] = @data[ctype][category][subcategory][tax] + amount
			else
				@data[ctype][category][subcategory][tax] = amount
			end
		end
	end

	def show
		@title = "Taxes for #{params[:year]} for #{params[:ctype]}/#{params[:cat]}/#{params[:subcat]}/#{params[:tax]}"
		categoryids = FinanceExpensesCategory.where("ctype = ? AND category = ? AND subcategory = ? AND tax = ?", params[:ctype], params[:cat], params[:subcat], params[:tax]).pluck('DISTINCT id')
		@items = FinanceExpensesItem.joins(:finance_expenses_what).where("EXTRACT(year FROM date) = ? AND finance_expenses_category_id in (?)", params[:year], categoryids).order('date')
		@summary = Hash.new
		@items.each do |item|
			amount = item.amount
			if item.pm == '-'
				amount = -amount
			end
			if @summary[item.finance_expenses_what.what]
				@summary[item.finance_expenses_what.what] = @summary[item.finance_expenses_what.what] + amount
			else
				@summary[item.finance_expenses_what.what] = amount
			end
		end
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE EXPENSES TAXES"
		end
	end

end
