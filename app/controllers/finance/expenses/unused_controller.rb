class Finance::Expenses::UnusedController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Unused'
		category_ids = FinanceWhat.all.pluck('DISTINCT finance_expenses_category_id')
		@categories = FinanceExpensesCategory.where("id NOT IN (?)", category_ids).order('ctype, category, subcategory')
		item_what_ids = FinanceExpensesItem.all.pluck('DISTINCT finance_what_id')
		what_maps_what_ids = FinanceWhatMap.all.pluck('DISTINCT finance_what_id')
		@whats = FinanceWhat.where("id NOT IN (?) AND id NOT IN (?)", item_what_ids, what_maps_what_ids).order('what')
	end

	def destroy
		if params[:table] == 'category'
			category = FinanceExpensesCategory.find(params[:id])
			if FinanceWhat.where("finance_expenses_category_id = ?", category.id).count > 0
				redirect_to finance_expenses_unused_index_path, alert: "Category in use: #{category.ctype}/#{category.category}/#{category.subcategory}/#{category.tax}"
			else
				category.delete
				redirect_to finance_expenses_unused_index_path, notice: "Category deleted: #{category.ctype}/#{category.category}/#{category.subcategory}/#{category.tax}"
			end
		elsif params[:table] == 'what'
			what = FinanceWhat.find(params[:id])
			if FinanceExpensesItem.where("finance_what_id = ?", what.id).count > 0
				redirect_to finance_expenses_unused_index_path, alert: "What in use by Item: #{what.what}"
			elsif FinanceWhatMap.where("finance_what_id = ?", what.id).count > 0
				redirect_to finance_expenses_unused_index_path, alert: "What in use by WhatMap: #{what.what}"
			else
				what.delete
				redirect_to finance_expenses_unused_index_path, notice: "What deleted: #{what.what}"
			end
		else
			redirect_to finance_expenses_unused_index_path, alert: "Unrecognized table: #{params[:table]}"
		end
	end

private

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE EXPENSES UNUSED"
		end
	end

end
