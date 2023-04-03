class Genealogy::InfoSourcesController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	def new
		@info = GenealogyInfo.find(params[:info_id].to_i)
		@title = "Add a Source for #{@info.itype}"
		@source = GenealogyInfoSource.new
		@source.genealogy_info_id = @info.id
		@sources = []
		GenealogySource.all.order('title').each  do |source|
			@sources.push([source.title, source.id])
		end
	end

	def create
		@source = GenealogyInfoSource.new(info_source_params)
		@source.save
		@info = GenealogyInfo.find(@source.genealogy_info_id)
		redirect_to edit_genealogy_info_path(@source.genealogy_info_id), notice: "Source added"
	end

	def edit
		@info = GenealogyInfo.find(params[:info_id].to_i)
		@title = "Edit a Source for #{@info.itype}"
		@source = GenealogyInfoSource.find(params[:id].to_i)
		@sources = []
		GenealogySource.all.order('title').each  do |source|
			@sources.push([source.title, source.id])
		end
	end

	def update
		@source = GenealogyInfoSource.find(params[:id].to_i)
		@source.update(info_source_params)
		@source.save
		redirect_to edit_genealogy_info_path(@source.genealogy_info_id), notice: "Source updated"
	end

	def destroy
		@source = GenealogyInfoSource.find(params[:id])
		redirect_to edit_genealogy_info_path(@source.genealogy_info_id), notice: "Source removed"
		@source.delete
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

	def info_source_params
		params.require(:genealogy_info_source).permit(:genealogy_info_id, :genealogy_source_id, :page, :quay)
	end

end
