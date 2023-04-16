class Finance::Expenses::CategoriesController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Categories'
		@categories = FinanceCategory.all.order('ctype, category, subcategory')
	end

	def new
		@title = 'New Category'
		@category = FinanceCategory.new
	end

	def create
		@category = FinanceCategory.new(category_params)
		if @category.save
			redirect_to finance_expenses_categories_path, notice: 'Category Added'
		else
			redirect_to finance_expenses_categories_path, alert: 'Failed to create Category'
		end
	end

	def edit
		@title = 'Edit Category'
		@category = FinanceCategory.find(params[:id])
	end

	def update
		@category = FinanceCategory.find(params[:id])
		if @category.update(category_params)
			redirect_to finance_expenses_categories_path, notice: 'Category Updated'
		else
			redirect_to finance_expenses_categories_path, alert: 'Failed to update Category'
		end
	end

	def show
		@category = FinanceCategory.find(params[:id])
		@title = "What maps to #{@category.ctype}/#{@category.category}/#{@category.subcategory}"
		@whats = FinanceWhat.where("finance_category_id = ?", @category.id).order('what')
	end

	def destroy
		@category = FinanceCategory.find(params[:id])
		if FinanceWhat.where("finance_category_id = ?", @category.id).count > 0
			redirect_to finance_expenses_categories_path, alert: "Category #{@category.ctype}/#{@category.category}/#{@category.subcategory}/#{@category.tax} is in use by a What"
		else
			@category.delete
			redirect_to finance_expenses_categories_path, notice: "Category #{@category.ctype}/#{@category.category}/#{@category.subcategory}/#{@category.tax} Deleted"
		end
	end

private
	
	def category_params
		params.require(:finance_category).permit(:ctype, :category, :subcategory, :tax)
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "inadequate permissions: FINANCE CATEGORIES"
		end
	end

end
