class Finance::Expenses::WhatsController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'What To Category Map'
		@whats = get_whats()
		set_sort_filter(columnlist())
		@whats = filter(@whats)
		@whats = sort(@whats)
	end

	def new
		@title = 'New What Map'
		@what = FinanceWhat.new
		set_sort_filter(columnlist())
		@categories = FinanceExpensesCategory.all.order('ctype, category, subcategory, tax')
	end

	def create
		@what = FinanceWhat.new(what_params)
		set_sort_filter(columnlist())
		if @what.save
			redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), notice: 'What Map Added'
		else
			redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), alert: 'Failed to create What Map'
		end
	end

	def edit
		@title = 'Edit What Map'
		@what = FinanceWhat.find(params[:id])
		set_sort_filter(columnlist())
		@categories = FinanceExpensesCategory.all.order('ctype, category, subcategory, tax')
	end

	def update
		@what = FinanceWhat.find(params[:id])
		set_sort_filter(columnlist())
		if @what.update(what_params)
			redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), notice: 'What map Updated'
		else
			redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), alert: 'Failed to create What map'
		end
	end

	def show
		@what = FinanceWhat.find(params[:id])
		set_sort_filter(columnlist())
		@title = "Where is '#{@what.what}'"
		@items = FinanceExpensesItem.where("finance_what_id = ?", @what.id).order('date')
	end

	def remap
		@title = 'Remap specified What to another what'
		@what = FinanceWhat.find(params[:id])
		set_sort_filter(columnlist())
		@whats = [['', 0]]
		FinanceWhat.where("id != ?", @what.id).order('what').each do |what|
			@whats.push([what.what, what.id])
		end
	end

	def remapupdate
		@id = params[:id]
		@what = FinanceWhat.find(@id)
		set_sort_filter(columnlist())
		@newid = params[:newid]
		@newwhat = FinanceWhat.find(@newid)
		# update WhatMaps
		FinanceExpensesWhatMap.where("finance_what_id = ?", @id).each do |map|
			map.finance_what_id = @newid
			map.save
		end
		count = 0
		FinanceExpensesItem.where("finance_what_id = ?", @id).count
		# update Items
		FinanceExpensesItem.where("finance_what_id = ?", @id).each do |item|
			item.finance_what_id = @newid
			item.save
			count += 1
		end
		FinanceWhat.find(@id).delete
		redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), notice: "#{count} '#{@what.what}' remapped to '#{@newwhat.what}'"
	end

	def destroy
		@what = FinanceWhat.find(params[:id])
		set_sort_filter(columnlist())
		if FinanceExpensesItem.where("finance_what_id = ?", @what.id).count > 0
			redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), alert: "What #{@what.what} is in use by an Item"
		elsif FinanceExpensesWhatMap.where("finance_what_id = ?", @what.id).count > 0
			redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), alert: "What #{@what.what} is in use by a WhatMap"
		else
			@what.delete
			redirect_to finance_expenses_whats_path(sort: @sort, filters: @filters), notice: "What #{@what.what} Deleted"
		end
	end

private
	
	def what_params
		params.require(:finance_what).permit(:what, :finance_expenses_category_id)
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to root_url, alert: "inadequate permissions: FINANCE EXPENSES"
		end
	end

	def columnlist
		return(['what', 'ctype', 'category', 'subcategory', 'tax'])
	end

	def get_whats
		@categorymap = Hash.new
		FinanceExpensesCategory.all.each do |category|
			@categorymap[category.id] = category
		end
		whats = Hash.new
		FinanceWhat.joins(:finance_expenses_category).all.order('ctype, category, subcategory, what').each do |what|
			whats[what.id] = Hash.new
			whats[what.id]['what'] = what.what
			whats[what.id]['ctype'] = @categorymap[what.finance_expenses_category_id].ctype
			whats[what.id]['category'] = @categorymap[what.finance_expenses_category_id].category
			whats[what.id]['subcategory'] = @categorymap[what.finance_expenses_category_id].subcategory
			whats[what.id]['tax'] = @categorymap[what.finance_expenses_category_id].tax
		end
		return whats
	end

end
