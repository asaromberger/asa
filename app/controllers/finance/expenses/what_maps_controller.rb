class Finance::Expenses::WhatMapsController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Whatmap Map'
		@whatmaps = get_whatmaps()
		set_sort_filter(columnlist())
		@whatmaps = filter(@whatmaps)
		@whatmaps = sort(@whatmaps)
		@sorts = @columns
	end

	def new
		@title = 'New WhatMap Map'
		@whatmap = FinanceWhatMap.new
		set_sort_filter(columnlist())
		@whats = FinanceWhat.all.order('what')
	end

	def create
		@whatmap = FinanceWhatMap.new(whatmap_params)
		set_sort_filter(columnlist())
		if @whatmap.save
			redirect_to finance_expenses_what_maps_path(sort: @sort, filters: @filters), notice: "WhatMap #{@whatmap.whatmap} Added"
		else
			redirect_to finance_expenses_what_maps_path(sort: @sort, filters: @filters), alert: 'Failed to create WhatMap Map'
		end
	end

	def edit
		@title = 'Edit WhatMap Map'
		@whatmap = FinanceWhatMap.find(params[:id])
		set_sort_filter(columnlist())
		@whats = FinanceWhat.all.order('what')
	end

	def update
		@whatmap = FinanceWhatMap.find(params[:id])
		set_sort_filter(columnlist())
		if @whatmap.update(whatmap_params)
			redirect_to finance_expenses_what_maps_path(sort: @sort, filters: @filters), notice: "WhatMap #{@whatmap.whatmap} Updated"
		else
			redirect_to finance_expenses_what_maps_path(sort: @sort, filters: @filters), alert: 'Failed to udate WhatMap map'
		end
	end

	def destroy
		@whatmap = FinanceWhatMap.find(params[:id])
		set_sort_filter(columnlist())
		@whatmap.delete
		redirect_to finance_expenses_what_maps_path(sort: @sort, filters: @filters), notice: "WhatMap #{@whatmap.whatmap} Deleted"
	end

private
	
	def whatmap_params
		params.require(:finance_what_map).permit(:whatmap, :finance_what_id)
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE EXPENSES WHATMAPS"
		end
	end

	def columnlist
		return(['what', 'map'])
	end

	def get_whatmaps
		whatmaps = Hash.new
		FinanceWhatMap.all.order('whatmap').each do |whatmap|
			whatmaps[whatmap.id] = Hash.new
			whatmaps[whatmap.id]['what'] = whatmap.whatmap
			whatmaps[whatmap.id]['map'] = whatmap.finance_what.what
		end
		return whatmaps
	end

end
