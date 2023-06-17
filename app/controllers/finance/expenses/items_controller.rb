class Finance::Expenses::ItemsController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		if params[:year].blank?
			@year = Time.now.year
		else
			@year = params[:year]
		end
		@title = "#{@year} Expenses"
		@years = []
		FinanceExpensesItem.all.pluck(Arel.sql("DISTINCT EXTRACT(year FROM date)")).each do |year|
			@years.push(year.to_i)
		end
		@years = @years.sort.reverse
		# build what_id to what and cat_id tables
		@whats = Hash.new
		@whatcatids = Hash.new
		FinanceWhat.all.each do |what|
			@whats[what.id] = what.what
			@whatcatids[what.id] = what.finance_category_id
		end
		# build cat_id to ctype, category, subcategory, tax tables
		@ctypes = Hash.new
		@categories = Hash.new
		@subcategories = Hash.new
		@taxes = Hash.new
		FinanceCategory.all.each do |category|
			@ctypes[category.id] = category.ctype
			@categories[category.id] = category.category
			@subcategories[category.id] = category.subcategory
			@taxes[category.id] = category.tax
		end
		@items = get_items()
		set_sort_filter(columnlist())
		@items = filter(@items)
		@items = sort(@items)
	end

	def new
		@title = 'New Item'
		@year = params[:year]
		@item = FinanceExpensesItem.new
		set_sort_filter(columnlist())
		if @year.to_i == Time.now.year
			@item.date = Time.now.to_date
		else
			@item.date = Date.new(@year.to_i, 1, 1)
		end
		@item.pm = '-'
		@whats = FinanceWhat.all.order('what')
	end

	def create
		@item = FinanceExpensesItem.new(item_params)
		set_sort_filter(columnlist())
		@year = params[:year]
		if @item.save
			redirect_to finance_expenses_items_path(year: @year, sort: @sort, filters: @filters), notice: 'Item Added'
		else
			redirect_to finance_expenses_items_path(year: @year, sort: @sort, filters: @filters), alert: 'Failed to add Item'
		end
	end

	def edit
		@title = 'Edit Item'
		@year = params[:year]
		@item = FinanceExpensesItem.find(params[:id])
		set_sort_filter(columnlist())
		@whats = FinanceWhat.all.order('what')
	end

	def update
		@year = params[:year]
		@item = FinanceExpensesItem.find(params[:id])
		set_sort_filter(columnlist())
		if @item.update(item_params)
			redirect_to finance_expenses_items_path(year: @year, sort: @sort, filters: @filters), notice: 'Item Updated'
		else
			redirect_to finance_expenses_items_path(year: @year, sort: @sort, filters: @filters), alert: 'Failed to update Item'
		end
	end

	def destroy
		@year = params[:year]
		@item = FinanceExpensesItem.find(params[:id])
		set_sort_filter(columnlist())
		@item.delete
		redirect_to finance_expenses_items_path(year: @year, sort: @sort, filters: @filters), notice: "Item #{@item.date} #{@item.finance_what.what} Deleted"
	end

private

	def item_params
		params.require(:finance_expenses_item).permit(:date, :pm, :checkno, :finance_what_id, :amount)
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "inadequate permissions: FINANCE ITEMS"
		end
	end

	def columnlist
		return(['date', 'pm', 'checkno', 'what', 'amount', 'ctype', 'category', 'subcategory', 'tax'])
	end

	def get_items
		items = Hash.new
		FinanceExpensesItem.where("EXTRACT(year FROM date) = ?", @year).order('date').each do |item|
			items[item.id] = Hash.new
			items[item.id]['date'] = item.date
			items[item.id]['pm'] = item.pm
			items[item.id]['checkno'] = item.checkno
			items[item.id]['what'] = @whats[item.finance_what_id]
			items[item.id]['amount'] = item.amount
			items[item.id]['ctype'] = @ctypes[@whatcatids[item.finance_what_id]]
			items[item.id]['category'] = @categories[@whatcatids[item.finance_what_id]]
			items[item.id]['subcategory'] = @subcategories[@whatcatids[item.finance_what_id]]
			items[item.id]['tax'] = @taxes[@whatcatids[item.finance_what_id]]
		end
		return items
	end

end
