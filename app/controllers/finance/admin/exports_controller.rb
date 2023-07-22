class Finance::Admin::ExportsController < ApplicationController

	before_action :require_signed_in
	before_action :require_admin

	def index
		@title = 'Export Tables'
	end

	def show
		@title = 'Export Results'
		@messages = []
		content = ""

		# expenses_accountmap account ctype
		FinanceExpensesAccountmap.all.order('id').each do |map|
			content += "\"expenses_accountmap\",\"#{map.account}\",\"#{map.ctype}\"\n"
		end

		# expenses_category ctype category subcategory tax
		expenses_categories = Hash.new
		FinanceExpensesCategory.all.order('id').each do |map|
			content += "\"expenses_category\",\"#{map.ctype}\",\"#{map.category}\",\"#{map.subcategory}\",\"#{map.tax}\"\n"
			expenses_categories[map.id] = [map.ctype, map.category, map.subcategory, map.tax]
		end

		# expenses_what what ctype category subcategory tax
		expenses_whats = Hash.new
		FinanceExpensesWhat.all.order('id').each do |map|
			tctype = expenses_categories[map.finance_expenses_category_id][0]
			tcategory = expenses_categories[map.finance_expenses_category_id][1]
			tsubcategory = expenses_categories[map.finance_expenses_category_id][2]
			ttax = expenses_categories[map.finance_expenses_category_id][3]
			content += "\"expenses_what\",\"#{map.what}\",\"#{tctype}\",\"#{tcategory}\",\"#{tsubcategory}\",\"#{ttax}\"\n"
			expenses_whats[map.id] = map.what
		end

		# expenses_item date pm checkno what amount
		FinanceExpensesItem.all.order('id').each do |map|
			twhat = expenses_whats[map.finance_expenses_what_id]
			content += "\"expenses_item\",\"#{map.date}\",\"#{map.pm}\",\"#{map.checkno}\",\"#{twhat}\",\"#{map.amount}\"\n"
		end

		# expenses_what_map whatmap what
		FinanceExpensesWhatMap.all.order('id').each do |map|
			twhat = expenses_whats[map.finance_expenses_what_id]
			content += "\"expenses_what_map\",\"#{map.whatmap}\",\"#{twhat}\"\n"
		end
		
		# investments_account name
		investments_accounts = Hash.new
		FinanceInvestmentsAccount.all.order('id').each do |map|
			content += "\"investments_account\",\"#{map.name}\"\n"
			investments_accounts[map.id] = map.name
		end

		# investments_fund account fund atype closed
		investments_funds = Hash.new
		FinanceInvestmentsFund.all.order('id').each do |map|
			taccount = investments_accounts[map.finance_investments_account_id]
			content += "\"investments_fund\",\"#{taccount}\",\"#{map.fund}\",\"#{map.atype}\",\"#{map.closed}\"\n"
			investments_funds[map.id] = [taccount, map.fund]
		end

		# investments_investment account fund date value shares pershare guaranteed
		FinanceInvestmentsInvestment.all.order('id').each do |map|
			taccount = investments_funds[map.finance_investments_fund_id][0]
			tfund = investments_funds[map.finance_investments_fund_id][1]
			content += "\"investments_investment\",\"#{taccount}\",\"#{tfund}\",\"#{map.date}\",\"#{map.value}\",\"#{map.shares}\",\"#{map.pershare}\",\"#{map.guaranteed}\"\n"
		end

		# investments_rebalance account fund target
		FinanceInvestmentsRebalance.all.order('id').each do |map|
			taccount = investments_funds[map.finance_investments_fund_id][0]
			tfund = investments_funds[map.finance_investments_fund_id][1]
			content += "\"investment_rebalance\",\"#{taccount}\",\"#{tfund}\",\"#{map.target}\"\n"
		end

		# investments_summary
		investments_summaries = Hash.new
		FinanceInvestmentsSummary.all.order('id').each do |map|
			content += "\"investments_summary\",\"#{map.stype}\",\"#{map.priority}\"\n"
			investments_summaries[map.id] = map.stype
		end

		FinanceInvestmentsSummaryContent.all.order('id').each do |map|
			taccount = investments_accounts[map.finance_investments_account_id]
			tsummary = investments_summaries[map.finance_investments_summary_id]
			content += "\"investment_summary_content\",\"#{taccount}\",\"#{tsummary}\"\n"
		end

		send_data(content, type: 'application/csv', filename: 'Financials.csv', disposition: :inline)
		
	end

private
	
	def require_admin
		unless current_user_role('finance_admin')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE ADMIN EXPORT"
		end
	end

end
