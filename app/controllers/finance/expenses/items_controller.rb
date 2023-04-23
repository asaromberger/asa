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
		FinanceItem.all.pluck(Arel.sql("DISTINCT EXTRACT(year FROM date)")).each do |year|
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
		get_items()
		set_sort_filter()
		filter(@items)
		sort(@items)
		@sorts = @columns
	end

	def new
		@title = 'New Item'
		@year = params[:year]
		@item = FinanceItem.new
		@item.date = Date.new(@year.to_i, 1, 1)
		@item.pm = '-'
		@whats = FinanceWhat.all.order('what')
	end

	def create
		@item = FinanceItem.new(item_params)
		@year = params[:year]
		if @item.save
			redirect_to finance_expenses_items_path(year: @year), notice: 'Item Added'
		else
			redirect_to finance_expenses_items_path(year: @year), alert: 'Failed to add Item'
		end
	end

	def edit
		@title = 'Edit Item'
		@year = params[:year]
		@item = FinanceItem.find(params[:id])
		@whats = FinanceWhat.all.order('what')
	end

	def update
		@year = params[:year]
		@item = FinanceItem.find(params[:id])
		if @item.update(item_params)
			redirect_to finance_expenses_items_path(year: @year), notice: 'Item Updated'
		else
			redirect_to finance_expenses_items_path(year: @year), alert: 'Failed to update Item'
		end
	end

	def destroy
		@year = params[:year]
		@item = FinanceItem.find(params[:id])
		@item.delete
		redirect_to finance_expenses_items_path(year: @year), notice: "Item #{@item.date} #{@item.finance_what.what} Deleted"
	end

private

	def item_params
		params.require(:finance_item).permit(:date, :pm, :checkno, :finance_what_id, :amount)
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
		@items = Hash.new
		FinanceItem.where("EXTRACT(year FROM date) = ?", @year).order('date').each do |item|
			@items[item.id] = Hash.new
			@items[item.id]['date'] = item.date
			@items[item.id]['pm'] = item.pm
			@items[item.id]['checkno'] = item.checkno
			@items[item.id]['what'] = @whats[item.finance_what_id]
			@items[item.id]['amount'] = item.amount
			@items[item.id]['ctype'] = @ctypes[@whatcatids[item.finance_what_id]]
			@items[item.id]['category'] = @categories[@whatcatids[item.finance_what_id]]
			@items[item.id]['subcategory'] = @subcategories[@whatcatids[item.finance_what_id]]
			@items[item.id]['tax'] = @taxes[@whatcatids[item.finance_what_id]]
		end
	end

	def set_sort_filter
		@columns = columnlist()
		if params[:sort]
			@sort = params[:sort]
		end
		@filters = Hash.new
		@columns.each do |column|
			if params[:filters] && params[:filters][column]
				@filters[column] = params[:filters][column]
			end
		end
	end

	def sort(data)
		if @sort
			@items = @items.sort_by { |id, values| values[@sort] }
		end
	end

	def filter(data)
		@filters.each do |column, pattern|
			if ! pattern.blank?
				pattern = pattern.downcase
				@items.each do |id, values|
					if values[column].blank? || ! values[column].to_s.downcase.match(pattern)
						@items.delete(id)
					end
				end
			end
		end
	end

end
