class Genealogy::TreeController < ApplicationController

	include GenealogyTreeHelper

	before_action :require_signed_in
	before_action :require_genealogy

	def index
		@title = "Tree"
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
				individual = GenealogyIndividual.find(family.genealogy_husband_id)
				GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
					if @marrieds[family.genealogy_husband_id].blank?
						@marrieds[family.genealogy_husband_id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					else
						@marrieds[family.genealogy_husband_id] = "#{@marrieds[family.genealogy_husband_id]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					end
				end
			end
			if !family.genealogy_wife_id.blank? && family.genealogy_wife_id != @individual.id
				individual = GenealogyIndividual.find(family.genealogy_wife_id)
				GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
					if @marrieds[family.genealogy_wife_id].blank?
						@marrieds[family.genealogy_wife_id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					else
						@marrieds[family.genealogy_wife_id] = "#{@marrieds[family.genealogy_wife_id]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					end
				end
			end
		end

		@tree = Hash.new
		tree(@tree, family_ids)

	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Genealogy Tree"
		end
	end

end
