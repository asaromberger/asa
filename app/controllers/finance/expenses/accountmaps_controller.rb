class Finance::Expenses::AccountmapsController < ApplicationController

	before_action :require_signed_in
	before_action :require_expenses

	def index
		@title = 'Account Number to Category Type'
		@accountmaps = FinanceExpensesAccountmap.all.order('account')
	end

	def new
		@title = 'New Account Map'
		@accountmap = FinanceExpensesAccountmap.new
	end

	def create
		@accountmap = FinanceExpensesAccountmap.new(accountmap_params)
		if @accountmap.save
			redirect_to finance_expenses_accountmaps_path, notice: 'Account Map Added'
		else
			redirect_to finance_expenses_accountmaps_path, alert: 'Failed to create Account Map'
		end
	end

	def edit
		@title = 'Edit Account Map'
		@accountmap = FinanceExpensesAccountmap.find(params[:id])
	end

	def update
		@accountmap = FinanceExpensesAccountmap.find(params[:id])
		if @accountmap.update(accountmap_params)
			redirect_to finance_expenses_accountmaps_path, notice: 'Account map Updated'
		else
			redirect_to finance_expenses_accountmaps_path, alert: 'Failed to create Account map'
		end
	end

	def destroy
		@accountmap = FinanceExpensesAccountmap.find(params[:id])
		@accountmap.delete
		redirect_to finance_expenses_accountmaps_path, notice: "Accountmap #{@accountmap.account} Deleted"
	end

private
	
	def accountmap_params
		params.require(:finance_expenses_accountmap).permit(:account, :ctype)
	end

	def require_expenses
		unless current_user_role('finance_expenses')
			redirect_to root_url, alert: "Inadequate permissions: FINANCE EXPENSES ACCOUNTMAPS"
		end
	end

end
