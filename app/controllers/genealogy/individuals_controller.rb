class Genealogy::IndividualsController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	include GenealogyIndividualHelper

	def new
		@individual = GenealogyIndividual.new
		@sex =  [['M', 'Male'], ['F', 'Female']]
	end

	def create
		@individual = GenealogyIndividual.new(individual_params)
		@individual.save
		@name = GenealogyInfo.new
		@name.genealogy_individual_id = @individual.id
		@name.itype = 'name'
		@name.date = Time.now.to_date
		@name.place = ''
		@name.note = ''
		@name.data = {
			given: params[:given],
			surname: params[:surname],
			suffix: params[:suffix]
		}
		@name.save
		redirect_to edit_genealogy_individual_path(@individual.id), notice: "Individual Created"
	end

	def edit
		@title = "Edit an Individual"
		@individual = GenealogyIndividual.find(params[:id])

		@names = Hash.new
		GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", @individual.id).order(Arel.sql("data -> 'given', data -> 'surname'")).each do |name|
			@names[name.id] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
		end
		@parents = Hash.new
		GenealogyChild.where("genealogy_individual_id = ?", @individual.id).each do |child|
			family = GenealogyFamily.find(child.genealogy_family_id)
			husband = ''
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", family.genealogy_husband_id).each do |name|
				if husband == ''
					husband = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				else
					husband = "#{husband} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				end
			end
			wife = ''
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", family.genealogy_wife_id).each do |name|
				if wife = ''
					wife = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				else
					wife = "#{wife} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				end
			end
			if husband == ''
				names = wife
			elsif wife == ''
				names = husband
			else
				names = husband + ' AND ' + wife
			end
			@parents[child.id] = names
		end

		@marrieds = Hash.new
		family_ids = []
		GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", @individual.id, @individual.id).each do |family|
			family_ids.push(family.id)
			if !family.genealogy_husband_id.blank? && family.genealogy_husband_id != @individual.id
				individual = GenealogyIndividual.find(family.genealogy_husband_id)
				GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
					tag = "#{@individual.id}:#{family.id}"
					if @marrieds[tag].blank?
						@marrieds[tag] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					else
						@marrieds[tag] = "#{@marrieds[tag]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					end
				end
			end
			if !family.genealogy_wife_id.blank? && family.genealogy_wife_id != @individual.id
				individual = GenealogyIndividual.find(family.genealogy_wife_id)
				GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
					tag = "#{@individual.id}:#{family.id}"
					if @marrieds[tag].blank?
						@marrieds[tag] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					else
						@marrieds[tag] = "#{@marrieds[tag]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
					end
				end
			end
		end

		@children = Hash.new
		GenealogyChild.where("genealogy_family_id in (?)", family_ids).each do |child|
			individual = GenealogyIndividual.find(child.genealogy_individual_id)
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
				tag = "#{@individual.id}:#{child.id}"
				if @children[tag].blank?
					@children[tag] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				else
					@children[tag] = "#{@children[tag]} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				end
			end
		end

		@births = info(@individual, 'birth')

		@deaths = info(@individual, 'death')

		@burrieds = info(@individual, 'burried')

		@baptisms = info(@individual, 'baptism')

		@residences = info(@individual, 'residence')

		@occupations = info(@individual, 'occupation')

		@events = info(@individual, 'event')

		@census = info(@individual, 'census')

	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

	def individual_params
		params.require(:genealogy_individual).permit(:uid, :refn, :sex)
	end

end
