class Genealogy::InformationController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	include GenealogyInformationHelper

	def index
		@title = "Information"
		@individual = GenealogyIndividual.find(params[:id])

		@names = GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", @individual.id).order(Arel.sql("data -> 'given', data -> 'surname'"))

		@parents = Hash.new
		GenealogyChild.where("genealogy_individual_id = ?", @individual.id).each do |child|
			family = GenealogyFamily.find(child.genealogy_family_id)
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", family.genealogy_husband_id).each do |name|
				if @parents[family.genealogy_husband_id].blank?
					@parents[family.genealogy_husband_id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				else
					@parents[family.genealogy_husband_id] = "#{@parents[family.genealogy_husband_id]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				end
			end
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", family.genealogy_wife_id).each do |name|
				if @parents[family.genealogy_wife_id].blank?
					@parents[family.genealogy_wife_id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				else
					@parents[family.genealogy_wife_id] = "#{@parents[family.genealogy_wife_id]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				end
			end
		end

		@marrieds = Hash.new
		family_ids = []
		GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", @individual.id, @individual.id).each do |family|
			family_ids.push(family.id)
			if !family.genealogy_husband_id.blank? && family.genealogy_husband_id != @individual.id
				individual = GenealogyIndividual.where("id = ?", family.genealogy_husband_id).first
				if individual
					GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
						if @marrieds[family.genealogy_husband_id].blank?
							@marrieds[family.genealogy_husband_id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
						else
							@marrieds[family.genealogy_husband_id] = "#{@marrieds[family.genealogy_husband_id]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
						end
					end
				end
			end
			if !family.genealogy_wife_id.blank? && family.genealogy_wife_id != @individual.id
				individual = GenealogyIndividual.where("id = ?", family.genealogy_wife_id).first
				if individual
					GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
						if @marrieds[family.genealogy_wife_id].blank?
							@marrieds[family.genealogy_wife_id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
						else
							@marrieds[family.genealogy_wife_id] = "#{@marrieds[family.genealogy_wife_id]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
						end
					end
				end
			end
		end

		@children = Hash.new
		GenealogyChild.where("genealogy_family_id in (?)", family_ids).each do |child|
			individual = GenealogyIndividual.find(child.genealogy_individual_id)
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
				if @children[individual.id].blank?
					@children[individual.id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				else
					@children[individual.id] = "#{@children[individual.id]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				end
			end
		end

		@births = information(@individual, 'birth')

		@deaths = information(@individual, 'death')

		@burrieds = information(@individual, 'burried')

		@baptisms = information(@individual, 'baptism')

		@residences = information(@individual, 'residence')

		@occupations = information(@individual, 'occupation')

		@events = information(@individual, 'event')

		@census = information(@individual, 'census')

	end

	def destroy
		@individual = GenealogyIndividual.find(params[:id].to_i)
		GenealogyInfo.where("genealogy_individual_id = ?", @individual.id).delete_all
		GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", @individual.id, @individual.id).each do |family|
			if family.genealogy_husband_id == @individual.id
				if family.genealogy_wife_id && family.genealogy_wife_id > 0
					family.genealogy_husband_id = 0
					family.save
				else
					GenealogyChild.where("genealogy_family_id = ?", family.id).delete_all
					family.delete
				end
			else
				if family.genealogy_husband_id && family.genealogy_husband_id > 0
					family.genealogy_wife_id = 0
					family.save
				else
					GenealogyChild.where("genealogy_family_id = ?", family.id).delete_all
					family.delete
				end
			end
		end
		GenealogyChild.where("genealogy_individual_id = ?", @individual.id).delete_all
		@individual.delete
		redirect_to genealogy_search_index_path, notice: "Individual Removed"
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

end
