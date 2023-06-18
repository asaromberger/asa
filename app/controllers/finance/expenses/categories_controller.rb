class Finance::Expenses::CategoriesController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Categories'
		@categories = get_categories()
		set_sort_filter(columnlist())
		@categories = filter(@categories)
		@categories = sort(@categories)
	end

	def new
		@title = 'New Category'
		@category = FinanceExpensesCategory.new
		set_sort_filter(columnlist())
	end

	def create
		@category = FinanceExpensesCategory.new(category_params)
		set_sort_filter(columnlist())
		if @category.save
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), notice: 'Category Added'
		else
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), alert: 'Failed to create Category'
		end
	end

	def edit
		@title = 'Edit Category'
		@category = FinanceExpensesCategory.find(params[:id])
		set_sort_filter(columnlist())
	end

	def update
		@category = FinanceExpensesCategory.find(params[:id])
		set_sort_filter(columnlist())
		if @category.update(category_params)
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), notice: 'Category Updated'
		else
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), alert: 'Failed to update Category'
		end
	end

	def show
		@category = FinanceExpensesCategory.find(params[:id])
		set_sort_filter(columnlist())
		@title = "What maps to #{@category.ctype}/#{@category.category}/#{@category.subcategory}"
		@whats = FinanceWhat.where("finance_expenses_category_id = ?", @category.id).order('what')
	end

	def destroy
		@category = FinanceExpensesCategory.find(params[:id])
		set_sort_filter(columnlist())
		if FinanceWhat.where("finance_expenses_category_id = ?", @category.id).count > 0
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), alert: "Category #{@category.ctype}/#{@category.category}/#{@category.subcategory}/#{@category.tax} is in use by a What"
		else
			@category.delete
			redirect_to finance_expenses_categories_path(sort: @sort, filters: @filters), notice: "Category #{@category.ctype}/#{@category.category}/#{@category.subcategory}/#{@category.tax} Deleted"
		end
	end

private
	
	def category_params
		params.require(:finance_expenses_category).permit(:ctype, :category, :subcategory, :tax)
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
		categories = Hash.new
		FinanceExpensesCategory.all.order('ctype, category, subcategory').each do |category|
			categories[category.id] = Hash.new
			categories[category.id]['ctype'] = category.ctype
			categories[category.id]['category'] = category.category
			categories[category.id]['subcategory'] = category.subcategory
			if category.tax.blank?
				categories[category.id]['tax'] = ''
			else
				categories[category.id]['tax'] = category.tax
			end
		end
		return categories
	end

end
