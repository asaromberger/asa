class Finance::Expenses::WhatsController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'What To Category Map'
		@whats = FinanceWhat.joins(:finance_category).all.order('ctype, category, subcategory, what')
		@categorymap = Hash.new
		FinanceCategory.all.each do |category|
			@categorymap[category.id] = Hash.new
			@categorymap[category.id]['ctype'] = category.ctype
			@categorymap[category.id]['category'] = category.category
			@categorymap[category.id]['subcategory'] = category.subcategory
			@categorymap[category.id]['tax'] = category.tax
		end
	end

	def new
		@title = 'New What Map'
		@what = FinanceWhat.new
		@categories = FinanceCategory.all.order('ctype, category, subcategory, tax')
	end

	def create
		@what = FinanceWhat.new(what_params)
		if @what.save
			redirect_to finance_expenses_whats_path, notice: 'What Map Added'
		else
			redirect_to finance_expenses_whats_path, alert: 'Failed to create What Map'
		end
	end

	def edit
		@title = 'Edit What Map'
		@what = FinanceWhat.find(params[:id])
		@categories = FinanceCategory.all.order('ctype, category, subcategory, tax')
	end

	def update
		@what = FinanceWhat.find(params[:id])
		if @what.update(what_params)
			redirect_to finance_expenses_whats_path, notice: 'What map Updated'
		else
			redirect_to finance_expenses_whats_path, alert: 'Failed to create What map'
		end
	end

	def show
		@what = FinanceWhat.find(params[:id])
		@title = "Where is '#{@what.what}'"
		@items = FinanceItem.where("finance_what_id = ?", @what.id).order('date')
	end

	def remap
		@title = 'Remap specified What to another what'
		@what = FinanceWhat.find(params[:id])
		@whats = [['', 0]]
		FinanceWhat.where("id != ?", @what.id).order('what').each do |what|
			@whats.push([what.what, what.id])
		end
	end

	def remapupdate
		@id = params[:id]
		@what = What.find(@id)
		@newid = params[:newid]
		@newwhat = What.find(@newid)
		# update WhatMaps
		FinanceWhatMap.where("finance_what_id = ?", @id).update_all(finance_what_id: @newid)
		count = FinanceItem.where("finance_what_id = ?", @id).count
		# update Items
		FinanceItem.where("finance_what_id = ?", @id).update_all(finance_what_id: @newid)
		FinanceWhat.find(@id).delete
		redirect_to finance_expenses_whats_path, notice: "#{count} '#{@what.what}' remapped to '#{@newwhat.what}'"
	end

	def destroy
		@what = FinanceWhat.find(params[:id])
		if FinanceItem.where("finance_what_id = ?", @what.id).count > 0
			redirect_to finance_expenses_whats_path, alert: "What #{@what.what} is in use by an Item"
		elsif FinanceWhatMap.where("finance_what_id = ?", @what.id).count > 0
			redirect_to finance_expenses_whats_path, alert: "What #{@what.what} is in use by a WhatMap"
		else
			@what.delete
			redirect_to finance_expenses_whats_path, notice: "What #{@what.what} Deleted"
		end
	end

private
	
	def what_params
		params.require(:finance_what).permit(:what, :finance_category_id)
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to root_url, alert: "inadequate permissions: FINANCE EXPENSES"
		end
	end

end
