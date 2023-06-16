class Finance::Trackings::TransfersController < ApplicationController

	before_action :require_signed_in
	before_action :require_trackings

	def index
		@title = "Transfers"
		@transfers = FinanceTracking.where("ptype = 'transfer'").order('date')
	end

	def new
		@title = 'New Transfer'
		@transfer = FinanceTracking.new
		@transfer.date = Time.now.to_date
		@transfer.ptype = 'transfer'
		@transfer.inc = 1
	end

	def create
		@transfer = FinanceTracking.new(transfer_params)
		if @transfer.save
			redirect_to finance_trackings_transfers_path, notice: 'Transfer Added'
		else
			redirect_to finance_trackings_transfers_path, alert: 'Failed to create Transfer'
		end
	end

	def edit
		@title = 'Edit Transfer'
		@transfer = FinanceTracking.find(params[:id])
	end

	def update
		@transfer = FinanceTracking.find(params[:id])
		if @transfer.update(transfer_params)
			redirect_to finance_trackings_transfers_path, notice: 'Transfer Updated'
		else
			redirect_to finance_trackings_transfers_path, alert: 'Failed to update Transfer'
		end
	end

	def destroy
		@transfer = FinanceTracking.find(params[:id])
		@transfer.delete
		redirect_to finance_trackings_transfers_path, notice: "Transfer Deleted"
	end

private
	
	def transfer_params
		params.require(:finance_tracking).permit(:ptype, :date, :what, :amount, :from, :to, :remaining, :inc, :note)
	end

	def require_trackings
		unless current_user_role('finance_trackings')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE TRACKINGS TRANSFERS"
		end
	end

end
