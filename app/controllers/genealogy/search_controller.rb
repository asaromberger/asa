class Genealogy::SearchController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	def index
		@title = "Genealogy Search"
		if params[:name]
			name = params[:name].downcase
t = Arel.sql("itype = 'name' AND lower(data -> 'given') LIKE '%#{name}%' OR lower(data -> 'surname') LIKE '%#{name}%'")
puts(t.to_json)
			@people = GenealogyInfo.where(Arel.sql("itype = 'name' AND lower(data -> 'given') LIKE '%#{name}%' OR lower(data -> 'surname') LIKE '%#{name}%'")).order(Arel.sql("data -> 'given', data -> 'surname'"))
		end
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

end
