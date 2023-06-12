class Finance::Payments::CdsController < ApplicationController

	before_action :require_signed_in
	before_action :require_payments

	def index
		@title = "CDs"
		@cds = FinancePayment.where("ptype = 'cd'").order('date')
	end

	def new
		@title = 'New CD'
		@cd = FinancePayment.new
		@cd.date = Time.now.to_date
		@cd.ptype = 'cd'
		@cd.inc = 1
	end

	def create
		@cd = FinancePayment.new(cd_params)
		if @cd.save
			redirect_to finance_payments_cds_path, notice: 'CD Added'
		else
			redirect_to finance_payments_cds_path, alert: 'Failed to create CD'
		end
	end

	def edit
		@title = 'Edit CD'
		@cd = FinancePayment.find(params[:id])
	end

	def update
		@cd = FinancePayment.find(params[:id])
		if @cd.update(cd_params)
			redirect_to finance_payments_cds_path, notice: 'CD Updated'
		else
			redirect_to finance_payments_cds_path, alert: 'Failed to update CD'
		end
	end

	def destroy
		@cd = FinancePayment.find(params[:id])
		@cd.delete
		redirect_to finance_payments_cds_path, notice: "CD Deleted"
	end

private
	
	def cd_params
		params.require(:finance_payment).permit(:ptype, :date, :what, :amount, :rate, :to, :note)
	end

	def require_payments
		unless current_user_role('finance_payments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE PAYMENTS CD"
		end
	end

end
