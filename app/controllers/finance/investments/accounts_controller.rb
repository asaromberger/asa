class Finance::Investments::AccountsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def new
		@status = params[:status]
		@title = 'New Account'
		@account = FinanceAccount.new
		@atypes = [['cash'], ['brokerage'], ['annuity']]
	end

	def create
		@status = params[:status]
		if FinanceAccount.where("account = ?", params[:finance_account][:account]).count > 0
				redirect_to finance_investments_investments_path(status: @status), alert: 'Account already exists'
		else
			@account = FinanceAccount.new(account_params)
			if @account.save
				redirect_to finance_investments_investments_path(status: @status), notice: 'Account Added'
			else
				redirect_to finance_investments_investments_path(status: @status), alert: 'Failed to create Account'
			end
		end
	end

	def edit
		@status = params[:status]
		@title = 'Edit Account'
		@account = FinanceAccount.find(params[:id])
		@atypes = [['cash'], ['brokerage'], ['annuity']]
	end

	def update
		@status = params[:status]
		fa = FinanceAccount.where("account = ?", params[:finance_account][:account]).first
		if fa && fa.id != params[:id].to_i
				redirect_to finance_investments_investments_path(status: @status), alert: 'Account already exists'
		else
			@account = FinanceAccount.find(params[:id])
			if @account.update(account_params)
				redirect_to finance_investments_investments_path(status: @status), notice: 'Account Updated'
			else
				redirect_to finance_investments_investments_path(status: @status), alert: 'Failed to update Account'
			end
		end
	end

	def destroy
		@status = params[:status]
		@account = FinanceAccount.find(params[:id])
		FinanceInvestment.where("finance_account_id = ?", @account.id).delete_all
		FinanceInvestmentMap.where("finance_account_id = ?", @account.id).delete_all
		FinanceRebalanceMap.where("finance_account_id = ?", @account.id).delete_all
		@account.delete
		redirect_to finance_investments_investments_path(status: @status), notice: "Account #{@account.account} Deleted"
	end

	def close
		@status = params[:status]
		@account = FinanceAccount.find(params[:id])
		investment = FinanceInvestment.where("finance_account_id = ?", @account.id).order('date DESC')
		if investment.count > 0
			investment = investment.first
			if investment.value != 0
				newinvestment = FinanceInvestment.new
				newinvestment.finance_account_id = @account.id
				newinvestment.date = investment.date + 1.day
				newinvestment.value = 0
				newinvestment.shares = 0
				newinvestment.pershare = 0
				newinvestment.guaranteed = 0
				newinvestment.save
			end
		end
		@account.closed = true
		@account.save
		redirect_to finance_investments_investments_path(status: @status), notice: "Account #{@account.account} Closed"
	end

private
	
	def account_params
		params.require(:finance_account).permit(:account, :atype)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS ACCOUNTS"
		end
	end

end
