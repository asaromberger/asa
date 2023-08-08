class Genealogy::DuplicatesController < ApplicationController

	before_action :require_signed_in
	before_action :require_genealogy

	def index
		@title = "Possible Duplicates"

		# individuals
		individuals = Hash.new
		GenealogyIndividual.all.each do |indi|
			individuals[indi.id] = Hash.new
			individuals[indi.id]['sex'] = indi.sex
		end
		GenealogyInfo.where("itype = 'birth'").each do |info|
			individuals[info.genealogy_individual_id]['birth'] = info.date
		end
		@names = Hash.new
		GenealogyInfo.where("itype = 'name'").each do |info|
			surname = info.data['surname']
			if ! @names[surname]
				@names[surname] = Hash.new
			end
			info.data['given'].split(/\s+/).each do |given|
				if ! @names[surname][given]
					@names[surname][given] = Hash.new
				end
				@names[surname][given][info.genealogy_individual_id] = Hash.new
				@names[surname][given][info.genealogy_individual_id]['id'] = info.genealogy_individual_id
				@names[surname][given][info.genealogy_individual_id]['given'] = info.data['given']
				@names[surname][given][info.genealogy_individual_id]['surname'] = info.data['surname']
				@names[surname][given][info.genealogy_individual_id]['suffix'] = info.data['suffix']
				@names[surname][given][info.genealogy_individual_id]['sex'] = individuals[info.genealogy_individual_id]['sex']
				@names[surname][given][info.genealogy_individual_id]['birth'] = individuals[info.genealogy_individual_id]['birth']
			end
		end
		@names = @names.sort_by { |surname, values| surname.downcase }

		@dups = []
		@names.each do |surname, svalues|
			svalues.each do |given, gvalues|
				if gvalues.count > 1
					t = Hash.new
					gvalues.each do |id, ivalues|
						t[id] = Hash.new
						t[id]['id'] = ivalues['id']
						t[id]['given'] = ivalues['given']
						t[id]['surname'] = ivalues['surname']
						t[id]['suffix'] = ivalues['suffix']
						t[id]['sex'] = ivalues['sex']
						t[id]['birth'] = ivalues['birth']
					end
					@dups.push(t)
				end
			end
		end
	end

	def new
		@title = "Individuals To Be Merged"
		if ! params[:primary]
			redirect_to genealogy_duplicates_path, alert: "No Primary Selected"
			return
		end
		if ! params[:secondary]
			redirect_to genealogy_duplicates_path, alert: "No Secondary Selected"
			return
		end
		if params[:primary] == params[:secondary]
			redirect_to genealogy_duplicates_path, alert: "Primary and Secondary are the same"
			return
		end
		@individuals = Hash.new
		primary_id = params[:primary].to_i
		individual = GenealogyIndividual.find(primary_id)
		@individuals[primary_id] = Hash.new
		@individuals[primary_id]['sex'] = individual.sex
		@individuals[primary_id]['names'] = Hash.new
		@individuals[primary_id]['primary'] = true
		GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", primary_id).each do |info|
			@individuals[primary_id]['names'][info.id] = "#{info.data['given']} #{info.data['surname']} #{info.data['suffix']}"
		end
		GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'birth'", primary_id).each do |info|
			@individuals[primary_id]['birth'] = info.date
		end
		secondary_id = params[:secondary].to_i
		individual = GenealogyIndividual.find(secondary_id)
		@individuals[secondary_id] = Hash.new
		@individuals[secondary_id]['sex'] = individual.sex
		@individuals[secondary_id]['names'] = Hash.new
		@individuals[secondary_id]['primary'] = false
		GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", secondary_id).each do |info|
			@individuals[secondary_id]['names'][info.id] = "#{info.data['given']} #{info.data['surname']} #{info.data['suffix']}"
		end
		GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'birth'", secondary_id).each do |info|
			@individuals[secondary_id]['birth'] = info.date
		end
	end

	def create
		primary = GenealogyIndividual.find(params[:primary])
		secondary = GenealogyIndividual.find(params[:secondary])
		# update info
		GenealogyInfo.where("genealogy_individual_id = ?", secondary.id).each do |info|
			info.genealogy_individual_id = primary.id
			gid = GenealogyInfo.where("genealogy_individual_id = ? AND itype = ?", info.genealogy_individual_id, info.itype).first
			if gid
puts("====== DUP INFO")
				if info.itype == 'name'
					if info.data['given'] == gid.data['given'] && info.data['surname'] == gid.data['surname'] && info.data['suffix'] == gid.data['suffix']
puts("====== NAME MATCH")
						info.delete
					else
puts("====== NAME MISMATCH")
						info.save
					end
				elsif info.date == gid.date && (info.itype == 'birth' || info.itype == 'burried' || info.itype == 'death')
puts("====== #{info.itype} MATCH")
					info.delete
				else
puts("====== #{info.itype} MISMATCH")
					info.save
				end
			else
				info.save
			end
			# update Family's
			GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", secondary.id, secondary.id).each do |family|
				if family.genealogy_husband_id == secondary.id
					family.genealogy_husband_id = primary.id
				else
					family.genealogy_wife_id = primary.id
				end
				# look for dup
				gfd = GenealogyFamily.where("genealogy_husband_id = ? AND genealogy_wife_id = ?", family.genealogy_husband_id, family.genealogy_wife_id).first
				if gfd
puts("====== Family MATCH")
					# there was a dup, update children & delete it
					GenealogyChild.where("genealogy_family_id = ?", family.id).each do |child|
						child.genealogy_family_id = gfd.id
						child.save
					end
					family.delete
				else
puts("====== DUP Family MISMATCH")
					family.save
				end
			end
			GenealogyChild.where("genealogy_individual_id = ?", secondary.id).each do |child|
				child.genealogy_individual_id = primary.id
				# look for dup
				gcd = GenealogyChild.where("genealogy_individual_id = ? AND genealogy_family_id = ?", child.genealogy_individual_id, child.genealogy_family_id).first
				if gcd
puts("====== Child MATCH")
					child.delete
				else
puts("====== Child MISMATCH")
					child.save
				end
			end
			secondary.delete
		end
		redirect_to edit_genealogy_individual_path(id: primary.id), notice: "Individuals merged - remove duplicate information"
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Genealogy Tree"
		end
	end

end
