class Genealogy::SourcesController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	def index
		@title = "Manage Sources"
		@sources = GenealogySource.all.order('title')
	end

	def new
		@title = "Add a Source"
		@source = GenealogySource.new
		@repos = []
		GenealogyRepo.all.order('name').each do |repo|
			@repos.push([repo.name, repo.id])
		end
	end

	def create
		@source = GenealogySource.new(source_params)
		@source.save
		redirect_to genealogy_sources_path, notice: "Source added"
	end

	def edit
		@title = "Edit a Source"
		@source = GenealogySource.find(params[:id])
		@repos = []
		GenealogyRepo.all.order('name').each do |repo|
			@repos.push([repo.name, repo.id])
		end
	end

	def update
		@source = GenealogySource.find(params[:id])
		@source.update(source_params)
		@source.save
		redirect_to genealogy_sources_path, notice: "Source updated"
	end

	def destroy
		@source = GenealogySource.find(params[:id])
		if GenealogyInfoSource.where("genealogy_source_id = ?", @source.id).count > 0
			redirect_to genealogy_sources_path, alert: "Source is in use: #{@source.title} is in use"
		else
			redirect_to genealogy_sources_path, notice: "Source removed"
			@source.delete
		end
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Genealogy Sources"
		end
	end

	def source_params
		params.require(:source).permit(:title, :abbreviation, :published, :refn, :genealogy_repo_id)
	end

end
