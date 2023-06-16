class Finance::Trackings::BillsController < ApplicationController

	before_action :require_signed_in
	before_action :require_trackings

	def index
		@title = "Bills"
		@bills = FinanceTracking.where("ptype = 'bill'").order('date')
	end

	def new
		@title = 'New Bill'
		@bill = FinanceTracking.new
		@bill.date = Time.now.to_date
		@bill.ptype = 'bill'
		@bill.inc = 1
	end

	def create
		@bill = FinanceTracking.new(bill_params)
		if @bill.save
			redirect_to finance_trackings_bills_path, notice: 'Bill Added'
		else
			redirect_to finance_trackings_bills_path, alert: 'Failed to create Bill'
		end
	end

	def edit
		@title = 'Edit Bill'
		@bill = FinanceTracking.find(params[:id])
	end

	def update
		@bill = FinanceTracking.find(params[:id])
		if @bill.update(bill_params)
			redirect_to finance_trackings_bills_path, notice: 'Bill Updated'
		else
			redirect_to finance_trackings_bills_path, alert: 'Failed to update Bill'
		end
	end

	def destroy
		@bill = FinanceTracking.find(params[:id])
		@bill.delete
		redirect_to finance_trackings_bills_path, notice: "Bill Deleted"
	end

private
	
	def bill_params
		params.require(:finance_tracking).permit(:ptype, :date, :what, :amount, :from, :inc, :note)
	end

	def require_trackings
		unless current_user_role('finance_trackings')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE TRACKINGS BILLS"
		end
	end

end
