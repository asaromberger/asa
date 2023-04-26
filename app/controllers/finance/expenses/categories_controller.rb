class Finance::Expenses::CategoriesController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Categories'
		get_categories()
		set_sort_filter()
		filter(@categories)
		sort(@categories)
		@sorts = @columns
	end

	def new
		@title = 'New Category'
		@category = FinanceCategory.new
		set_sort_filter()
	end

	def create
		@category = FinanceCategory.new(category_params)
		set_sort_filter()
		if @category.save
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), notice: 'Category Added'
		else
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), alert: 'Failed to create Category'
		end
	end

	def edit
		@title = 'Edit Category'
		@category = FinanceCategory.find(params[:id])
		set_sort_filter()
	end

	def update
		@category = FinanceCategory.find(params[:id])
		set_sort_filter()
		if @category.update(category_params)
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), notice: 'Category Updated'
		else
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), alert: 'Failed to update Category'
		end
	end

	def show
		@category = FinanceCategory.find(params[:id])
		set_sort_filter()
		@title = "What maps to #{@category.ctype}/#{@category.category}/#{@category.subcategory}"
		@whats = FinanceWhat.where("finance_category_id = ?", @category.id).order('what')
	end

	def destroy
		@category = FinanceCategory.find(params[:id])
		set_sort_filter()
		if FinanceWhat.where("finance_category_id = ?", @category.id).count > 0
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), alert: "Category #{@category.ctype}/#{@category.category}/#{@category.subcategory}/#{@category.tax} is in use by a What"
		else
			@category.delete
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), notice: "Category #{@category.ctype}/#{@category.category}/#{@category.subcategory}/#{@category.tax} Deleted"
		end
	end

private
	
	def category_params
		params.require(:finance_category).permit(:ctype, :category, :subcategory, :tax)
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "inadequate permissions: FINANCE EXPENSES CATEGORIES"
		end
	end

	def columnlist
		return(['ctype', 'category', 'subcategory', 'tax'])
	end

	def get_categories
		@categories = Hash.new
		FinanceCategory.all.order('ctype, category, subcategory').each do |category|
			@categories[category.id] = Hash.new
			@categories[category.id]['ctype'] = category.ctype
			@categories[category.id]['category'] = category.category
			@categories[category.id]['subcategory'] = category.subcategory
			if category.tax.blank?
				@categories[category.id]['tax'] = ''
			else
				@categories[category.id]['tax'] = category.tax
			end
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
			@categories = @categories.sort_by { |id, values| values[@sort].downcase }
		end
	end

	def filter(data)
		@filters.each do |column, pattern|
			if ! pattern.blank?
				pattern = pattern.downcase
				@categories.each do |id, values|
					if values[column].blank? || ! values[column].downcase.match(pattern)
						@categories.delete(id)
					end
				end
			end
		end
	end

end
