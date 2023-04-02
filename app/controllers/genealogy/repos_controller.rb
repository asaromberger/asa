class Genealogy::ReposController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	def index
		@title = "Manage Repos"
		@repos = GenealogyRepo.all.order('name')
	end

	def new
		@title = "Add a Repo"
		@repo = GenealogyRepo.new
	end

	def create
		@repo = GenealogyRepo.new(repo_params)
		@repo.save
		redirect_to genealogy_repos_path, notice: "Repo added"
	end

	def edit
		@title = "Edit a Repo"
		@repo = GenealogyRepo.find(params[:id])
	end

	def update
		@repo = GenealogyRepo.find(params[:id])
		@repo.update(repo_params)
		@repo.save
		redirect_to genealogy_repos_path, notice: "Repo updated"
	end

	def destroy
		@repo = GenealogyRepo.find(params[:id])
		if GenealogySource.where("genealogy_repo_id = ?", @repo.id).count > 0
			redirect_to genealogy_repos_path, alert: "Repo in use: #{@repo.name}"
		else
			redirect_to genealogy_repos_path, notice: "Repo removed"
			@repo.delete
		end
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

	def repo_params
		params.require(:genealogy_repo).permit(:name, :addr, :city, :state, :country)
	end

end
