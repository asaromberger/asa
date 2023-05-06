class Finance::Investments::InvestmentsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@status = params[:status]
		@title = 'Accounts'
		@accounts = Hash.new
		@errors = params[:errors]
		@exists = params[:exists]
		if @status == 'open'
			accounts = FinanceAccount.where('closed is NULL or closed = false').order('account')
		elsif @status == 'closed'
			accounts = FinanceAccount.where('closed = true').order('account')
		else
			accounts = FinanceAccount.all.order('account')
		end
		accounts.each do |account|
			@accounts[account.id] = Hash.new
			@accounts[account.id]['account'] = account.account
			@accounts[account.id]['type'] = account.atype
			investment = FinanceInvestment.where("finance_account_id = ?", account.id).order('date DESC')
			if investment.count > 0
				@accounts[account.id]['date'] = investment.first.date
				@accounts[account.id]['value'] = investment.first.value
			else
				@accounts[account.id]['date'] = ''
				@accounts[account.id]['value'] = 0
			end
			@accounts[account.id]['closed'] = account.closed
		end
	end

	def show
		@status = params[:status]
		@account = FinanceAccount.find(params[:id])
		@title = "#{@account.account}"
		if @account.atype == 'cash'
			@headers = []
		elsif @account.atype == 'brokerage'
			@headers = ['Shares', 'Per Share']
		elsif @account.atype == 'annuity'
			@headers = ['Guaranteed', 'Yearly']
		end
		@errors = params[:errors]
		@exists = params[:exists]
		@investments = Hash.new
		FinanceInvestment.where("finance_account_id = ?", @account.id).order('date DESC').each do |investment|
			@investments[investment.id] = Hash.new
			@investments[investment.id]['date'] = investment.date
			@investments[investment.id]['value'] = investment.value
			if @account.atype == 'cash'
			elsif @account.atype == 'brokerage'
				@investments[investment.id]['Shares'] = investment.shares
				@investments[investment.id]['Per Share'] = investment.pershare
			elsif @account.atype == 'annuity'
				@investments[investment.id]['Guaranteed'] = investment.guaranteed
				@investments[investment.id]['Yearly'] = investment.guaranteed * 0.05
			end
		end
	end

	def new
		@status = params[:status]
		@account = FinanceAccount.find(params[:id])
		@title = "New Entry for #{@account.account}"
		@investment = FinanceInvestment.new
		if session['investmentdate'].blank?
			@investment.date = (Time.now - 1.month).end_of_month.to_date
		else
			@investment.date = session['investmentdate']
		end
		lastinvestment = FinanceInvestment.where("finance_account_id = ?", @account.id).order('date DESC').first
		if @account.atype == 'cash'
			@headers = ['value']
			if lastinvestment.blank?
				@investment.value = 0
			else
				@investment.value = lastinvestment.value
			end
		elsif @account.atype == 'brokerage'
			@headers = ['shares', 'pershare']
			if lastinvestment.blank?
				@investment.shares = 0
				@investment.pershare = 0
			else
				@investment.shares = lastinvestment.shares
				@investment.pershare = lastinvestment.pershare
			end
		elsif @account.atype == 'annuity'
			@headers = ['value', 'guaranteed']
			if lastinvestment.blank?
				@investment.value = 0
				@investment.guaranteed = 0
			else
				@investment.value = lastinvestment.value
				@investment.guaranteed = lastinvestment.guaranteed
			end
		end
	end

	def create
		@status = params[:status]
		@account = FinanceAccount.find(params[:account])
		@investment = FinanceInvestment.new(investment_params)
		@investment.finance_account_id = @account.id
		if @account.atype == 'brokerage'
			@investment.value = @investment.shares * @investment.pershare
		end
		session['investmentdate'] = @investment.date
		if @investment.save
			redirect_to finance_investments_investments_path(status: @status), notice: 'Item Added'
		else
			redirect_to finance_investments_investments_path(status: @status), alert: 'Failed to create Item'
		end
	end

	def edit
		@status = params[:status]
		@account = FinanceAccount.find(params[:account])
		@title = "Edit Entry for #{@account.account}"
		@investment = FinanceInvestment.find(params[:id])
		if @account.atype == 'cash'
			@headers = ['value']
		elsif @account.atype == 'brokerage'
			@headers = ['shares', 'pershare']
		elsif @account.atype == 'annuity'
			@headers = ['value', 'guaranteed']
		end
	end

	def update
		@status = params[:status]
		@account = FinanceAccount.find(params[:account])
		@investment = FinanceInvestment.find(params[:id])
		if @account.atype == 'brokerage'
			params[:finance_investment][:value] = params[:finance_investment][:shares].to_f * params[:finance_investment][:pershare].to_f
		end
		session['investmentdate'] = @investment.date
		if @investment.update(investment_params)
			redirect_to finance_investments_investments_path(status: @status), notice: 'Item Updated'
		else
			redirect_to finance_investments_investments_path(status: @status), alert: 'Failed to update Item'
		end
	end

	def destroy
		@status = params[:status]
		@investment = FinanceInvestment.find(params[:id])
		@investment.delete
		redirect_to finance_investments_investments_path(status: @status), notice: "Item Deleted"
	end

private
	
	def investment_params
		params.require(:finance_investment).permit(:date, :value, :shares, :pershare, :guaranteed)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS INVESTMENTS"
		end
	end

end
