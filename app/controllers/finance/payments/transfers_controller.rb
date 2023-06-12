class Finance::Payments::TransfersController < ApplicationController

	before_action :require_signed_in
	before_action :require_payments

	def index
		@title = "Transfers"
		@transfers = FinancePayment.where("ptype = 'transfer'").order('date')
	end

	def new
		@title = 'New Transfer'
		@transfer = FinancePayment.new
		@transfer.date = Time.now.to_date
		@transfer.ptype = 'transfer'
		@transfer.inc = 1
	end

	def create
		@transfer = FinancePayment.new(transfer_params)
		if @transfer.save
			redirect_to finance_payments_transfers_path, notice: 'Transfer Added'
		else
			redirect_to finance_payments_transfers_path, alert: 'Failed to create Transfer'
		end
	end

	def edit
		@title = 'Edit Transfer'
		@transfer = FinancePayment.find(params[:id])
	end

	def update
		@transfer = FinancePayment.find(params[:id])
		if @transfer.update(transfer_params)
			redirect_to finance_payments_transfers_path, notice: 'Transfer Updated'
		else
			redirect_to finance_payments_transfers_path, alert: 'Failed to update Transfer'
		end
	end

	def destroy
		@transfer = FinancePayment.find(params[:id])
		@transfer.delete
		redirect_to finance_payments_transfers_path, notice: "Transfer Deleted"
	end

private
	
	def transfer_params
		params.require(:finance_payment).permit(:ptype, :date, :what, :amount, :from, :to, :remaining, :dom, :inc, :note)
	end

	def require_payments
		unless current_user_role('finance_payments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE PAYMENTS TRANSFERS"
		end
	end

end
