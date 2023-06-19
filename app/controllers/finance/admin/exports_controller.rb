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

		# accountmaps
		FinanceExpensesAccountmap.all.order('id').each do |map|
			content += "\"accountmap\",\"#{map.account}\",\"#{map.ctype}\"\n"
		end

		# funds
		funds = Hash.new
		FinanceInvestmentsFund.all.order('id').each do |map|
			content += "\"fund\",\"#{map.fund}\",\"#{map.atype}\",\"#{map.closed}\"\n"
			funds[map.id] = map.fund
		end

		# categories
		categories = Hash.new
		FinanceExpensesCategory.all.order('id').each do |map|
			content += "\"category\",\"#{map.ctype}\",\"#{map.category}\",\"#{map.subcategory}\",\"#{map.tax}\"\n"
			categories[map.id] = [map.ctype, map.category, map.subcategory, map.tax]
		end

		# rebalance_types
		rebalance_types = Hash.new
		FinanceRebalanceType.all.order('id').each do |map|
			content += "\"rebalance_types\",\"#{map.rtype}\"\n"
			rebalance_types[map.id] = map.rtype
		end

		# summary_types
		summary_types = Hash.new
		FinanceSummaryType.all.order('id').each do |map|
			content += "\"summary_type\",\"#{map.stype}\",\"#{map.priority}\"\n"
			summary_types[map.id] = map.stype
		end

		# investment_maps fund summary_type
		FinanceInvestmentMap.all.order('id').each do |map|
			content += "\"investment_map\",\"#{funds[map.finance_investments_fund_id]}\",\"#{summary_types[map.finance_summary_type_id]}\"\n"
		end

		# investments     fund
		FinanceInvestment.all.order('id').each do |map|
			content += "\"investment\",\"#{funds[map.finance_investments_fund_id]}\",\"#{map.date}\",\"#{map.value}\",\"#{map.shares}\",\"#{map.pershare}\",\"#{map.guaranteed}\"\n"
		end

		# rebalance_maps  rebalance_type	fund
		FinanceRebalanceMap.all.order('id').each do |map|
			content += "\"rebalance_map\",\"#{rebalance_types[map.finance_rebalance_type_id]}\",\"#{funds[map.finance_investments_fund_id]}\",\"#{map.target}\"\n"
		end

		# whats           categories
		whats = Hash.new
		FinanceExpensesWhat.all.order('id').each do |map|
			content += "\"what\",\"#{map.what}\",\"#{categories[map.finance_expenses_category_id][0]}\",\"#{categories[map.finance_expenses_category_id][1]}\",\"#{categories[map.finance_expenses_category_id][2]}\",\"#{categories[map.finance_expenses_category_id][3]}\"\n"
			whats[map.id] = map.what
		end

		# items           whats
		FinanceExpensesItem.all.order('id').each do |map|
			content += "\"item\",\"#{map.date}\",\"#{map.pm}\",\"#{map.checkno}\",\"#{whats[map.finance_expenses_what_id]}\",\"#{map.amount}\"\n"
		end

		# what_maps       whats           categories
		FinanceExpensesWhatMap.all.order('id').each do |map|
			content += "\"what_map\",\"#{map.whatmap}\",\"#{whats[map.finance_expenses_what_id]}\"\n"
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
