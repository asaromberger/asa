class Finance::Investments::AccountsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@status = params[:status]
		if @status == 'open'
			fia_ids = FinanceInvestmentsFund.where("closed IS NULL OR closed != true").pluck('DISTINCT finance_investments_account_id')
			@accounts = FinanceInvestmentsAccount.where("id IN (?)", fia_ids).order('name')
			@title = 'Accounts with open funds'
		elsif @status == 'closed'
			fia_ids = FinanceInvestmentsFund.where("closed = true").pluck('DISTINCT finance_investments_account_id')
			@accounts = FinanceInvestmentsAccount.where("id IN (?)", fia_ids).order('name')
			@title = 'Accounts with closed funds'
		else
			@accounts = FinanceInvestmentsAccount.all.order('name')
			@title = 'All Accounts'
		end
		@totals = Hash.new
		@current = Hash.new
		@total = 0
		date = Time.new.to_date - 28.days
		@accounts.each do |account|
			@totals[account.id] = 0
			@current[account.id] = true
			FinanceInvestmentsFund.where("finance_investments_account_id = ? AND (closed IS NULL OR closed = false)", account.id).each do |fund|
				investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", fund.id).order('date DESC').first
				if investment
					@totals[account.id] += investment.value
					if investment.date < date
						@current[account.id] = false
					end
				end
			end
			@total += @totals[account.id]
		end
	end

	def new
		@status = params[:status]
		@title = 'New Account'
		@account = FinanceInvestmentsAccount.new
	end

	def create
		@status = params[:status]
		if FinanceInvestmentsAccount.where("name = ?", params[:finance_investments_account][:name]).count > 0
				redirect_to finance_investments_accounts_path(status: @status), alert: 'Account already exists'
		else
			@account = FinanceInvestmentsAccount.new(account_params)
			if @account.save
				redirect_to finance_investments_accounts_path(status: @status), notice: 'Account Added'
			else
				redirect_to finance_investments_accounts_path(status: @status), alert: 'Failed to create Account'
			end
		end
	end

	def edit
		@status = params[:status]
		@title = 'Edit Account'
		@account = FinanceInvestmentsAccount.find(params[:id])
	end

	def update
		@status = params[:status]
		fa = FinanceInvestmentsAccount.where("name = ?", params[:finance_investments_account][:name]).first
		if fa && fa.id != params[:id].to_i
				redirect_to finance_investments_accounts_path(status: @status), alert: 'Account already exists'
		else
			@account = FinanceInvestmentsAccount.find(params[:id])
			if @account.update(account_params)
				redirect_to finance_investments_accounts_path(status: @status), notice: 'Account Updated'
			else
				redirect_to finance_investments_accounts_path(status: @status), alert: 'Failed to update Account'
			end
		end
	end

	def destroy
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:id])
		if FinanceInvestmentsFund.where("finance_investments_account_id = ?", @account.id).count > 0
			redirect_to finance_investments_accounts_path(status: @status), alert: "Account #{@account.name} is in use and was not deleted"
		else
			@account.delete
			redirect_to finance_investments_accounts_path(status: @status), notice: "Account #{@account.name} Deleted"
		end
	end

private
	
	def account_params
		params.require(:finance_investments_account).permit(:name)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS ACCOUNTS"
		end
	end

end
