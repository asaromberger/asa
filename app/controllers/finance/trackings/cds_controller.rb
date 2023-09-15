class Finance::Trackings::CdsController < ApplicationController

	before_action :require_signed_in
	before_action :require_trackings

	def index
		@title = "CDs"
		@cds = FinanceTracking.where("ptype = 'cd'").order('date, what')
	end

	def new
		@title = 'New CD'
		@cd = FinanceTracking.new
		@cd.date = Time.now.to_date
		@cd.ptype = 'cd'
		@cd.inc = 1
	end

	def create
		@cd = FinanceTracking.new(cd_params)
		if @cd.save
			redirect_to finance_trackings_cds_path, notice: 'CD Added'
		else
			redirect_to finance_trackings_cds_path, alert: 'Failed to create CD'
		end
	end

	def edit
		@title = 'Edit CD'
		@cd = FinanceTracking.find(params[:id])
	end

	def update
		@cd = FinanceTracking.find(params[:id])
		if @cd.update(cd_params)
			redirect_to finance_trackings_cds_path, notice: 'CD Updated'
		else
			redirect_to finance_trackings_cds_path, alert: 'Failed to update CD'
		end
	end

	def destroy
		@cd = FinanceTracking.find(params[:id])
		@cd.delete
		redirect_to finance_trackings_cds_path, notice: "CD Deleted"
	end

private
	
	def cd_params
		params.require(:finance_tracking).permit(:ptype, :date, :what, :amount, :rate, :to, :note)
	end

	def require_trackings
		unless current_user_role('finance_trackings')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE TRACKINGS CD"
		end
	end

end
