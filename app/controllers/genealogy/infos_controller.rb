class Genealogy::InfosController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	def new
		type = params[:type]
		@title = "Add a #{type}"
		@info = GenealogyInfo.new
		@info.genealogy_individual_id = params[:genealogy_individual_id].to_i
		@info.itype = type
		@info.date = Time.now.to_date
		@info.place = ''
		@info.note = ''
		@info.data = {}
		@sources = []
	end

	def create
		@info = GenealogyInfo.new(info_params)
		@info.save
		redirect_to edit_genealogy_individual_path(@info.genealogy_individual_id), notice: "#{@info.itype} added"
	end

	def edit
		@info = GenealogyInfo.find(params[:id])
		@title = "Edit a #{@info.itype}"
		@sources = GenealogyInfoSource.where("genealogy_info_id = ?", @info.id)
	end

	def update
		@info = GenealogyInfo.find(params[:id])
		@info.update(info_params)
		@info.save
		redirect_to edit_genealogy_individual_path(@info.genealogy_individual_id), notice: "#{@info.itype} updated"
	end

	def destroy
		@info = GenealogyInfo.find(params[:id])
		redirect_to edit_genealogy_individual_path(@info.genealogy_individual_id), notice: "#{@info.itype} removed"
		GenealogyInfoSource.where("genealogy_info_id = ?", @info.id).delete_all
		@info.delete
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

	def info_params
		params.require(:genealogy_info).permit(:genealogy_individual_id, :itype, :date, :place, :note, data: params[:genealogy_info][:data].try(:keys))
	end

end
