class Genealogy::Admin::BulkInputController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy_admin

	include GenealogyBulkInputHelper

	def new
		@title = "Genealogy Bulk Input"
		@messages = []
		if params[:messages]
			params[:messages].sub(/\[/, '').sub(/\]$/, '').split(/,/).each do |message|
				@messages.push(message.gsub(/^"/, '').gsub(/"$/, ''))
			end
		end
	end

	def create
		@messages = []
		document = params[:document]
		lines = document.read
		lines = lines.encode('UTF-8', invalid: :replace, undef: :replace).gsub(/\r/,'')
		lines = lines.split(/\n/)
		# handle continuations
		ind = 0
		tind = 0
		lines.each do |line|
			if line.match('CONT')
				t = line.gsub(/^.*CONT\s*/, '')
				lines[tind] = lines[tind] + "\n" + t
				lines[ind] = lines[ind].gsub(/CONT.*/, 'CONT ')
			elsif line.match('CONC')
				t = line.gsub(/^.*CONC\s*/, '')
				lines[tind] = lines[tind] + t
				lines[ind] = lines[ind].gsub(/CONC.*/, 'CONC ')
			else
				tind = ind
			end
			ind = ind + 1
		end
		@lines = []
		@struct = []
		@indexes = Hash.new
		@indexes['NOTE'] = Hash.new
		@indexes['FAM'] = Hash.new
		@indexes['INDI'] = Hash.new
		@indexes['REPO'] = Hash.new
		@indexes['SUBM'] = Hash.new
		@indexes['SOUR'] = Hash.new
		lines.each do |line|
			indent = line.sub(/ .*/m, '').to_i
			line = line.sub(/^[^ ]* /, '')
			code = line.sub(/ .*/m, '').sub(/\s*$/, '')
			data = line.sub(/^[^ ]* /m, '').sub(/\s*$/, '')
			tmp = @struct
			index = @struct.count - 1
			if indent > 0
				(1..indent).each do |i|
					tmp = tmp[index]
					index = tmp.count - 1
				end
			end
			tmp[index + 1] = [indent, code, data]
			@lines.push([indent, code, data])
			# Create empty database entries
			if indent == 0
				if data.match(/^NOTE/)
					@indexes['NOTE'][code] = data.gsub(/^NOTE\s*/, '')
				elsif data == 'FAM'
					@indexes['FAM'][code] = GenealogyFamily.new
					@indexes['FAM'][code].save
				elsif data == 'INDI'
					@indexes['INDI'][code] = GenealogyIndividual.new
					@indexes['INDI'][code].save
				elsif data == 'REPO'
					@indexes['REPO'][code] = GenealogyRepo.new
					@indexes['REPO'][code].save
				elsif data == 'SUBM'
					# probably ignore submitter
				elsif data == 'SOUR'
					@indexes['SOUR'][code] = GenealogySource.new
					@indexes['SOUR'][code].save
				end
			end
		end
		@messages.push("NOTE #{@indexes['NOTE'].count}")
		@messages.push("FAM #{@indexes['FAM'].count}")
		@messages.push("INDI #{@indexes['INDI'].count}")
		@messages.push("REPO #{@indexes['REPO'].count}")
		@messages.push("SOUR #{@indexes['SOUR'].count}")
		@individuals = Hash.new
		@families = Hash.new
		@children = Hash.new
		@sources = Hash.new
		@repos = Hash.new
		@struct.each do |el0|
			if el0[2] == 'INDI'
				key = el0[1]
				@individuals[key] = Hash.new
				@individuals[key]['errors'] = []
				individual = @indexes['INDI'][key]
				(3..(el0.count - 1)).each do |i1|
					if el0[i1][1] == 'NAME'
						bicollect(individual, 'name', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'SEX'
						@individuals[key]['SEX'] = el0[i1][2]
						individual.sex = @individuals[key]['SEX']
					elsif el0[i1][1] == 'BIRT'
						bicollect(individual, 'birth', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'DEAT'
						bicollect(individual, 'death', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'BURI'
						bicollect(individual, 'burried', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == '_UID'
						@individuals[key]['UID'] = el0[i1][2]
					elsif el0[i1][1] == 'REFN'
						@individuals[key]['REFN'] = el0[i1][2]
					elsif el0[i1][1] == 'RESI'
						bicollect(individual, 'residence', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'OCCU'
						bicollect(individual, 'occupation', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'CENS'
						bicollect(individual, 'census', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'EVEN'
						bicollect(individual, 'event', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'BAPM'
						bicollect(individual, 'baptism', el0[i1], @individuals[key], @indexes['SOUR'])
					elsif el0[i1][1] == 'CHAN'
						(3..(el0[i1].count - 1)).each do |i2|
							if el0[i1][i2][1] == 'DATE'
								@individuals[key]['LASTUPDATE'] = el0[i1][i2][2]
							end
						end
					elsif el0[i1][1] == 'FAMS'
						@individuals[key]['FAMS'] = el0[i1][2]
					elsif el0[i1][1] == 'FAMC'
						@individuals[key]['FAMC'] = el0[i1][2]
					else
						@individuals[key]['errors'].push(el0[i1][1])
					end
				end
				individual.save
			elsif el0[2] == 'FAM'
				key = el0[1]
				@families[key] = Hash.new
				@families[key]['errors'] = []
				@families[key]['children'] = []
				family = @indexes['FAM'][key]
				(3..(el0.count - 1)).each do |i1|
					if el0[i1][1] == 'HUSB'
						family.genealogy_husband_id = @indexes['INDI'][el0[i1][2]].id
						@families[key]['husband'] = family.genealogy_husband_id
					elsif el0[i1][1] == 'WIFE'
						family.genealogy_wife_id = @indexes['INDI'][el0[i1][2]].id
						@families[key]['wife'] = family.genealogy_wife_id
					elsif el0[i1][1] == 'CHIL'
						child = GenealogyChild.new
						child.genealogy_individual_id = @indexes['INDI'][el0[i1][2]].id
						child.genealogy_family_id = family.id
						child.save
						@families[key]['children'].push(child.genealogy_individual_id)
					elsif el0[i1][1] == 'CHAN'
						(3..(el0[i1].count - 1)).each do |i2|
							if el0[i1][i2][1] == 'DATE'
								family.updated = el0[i1][i2][2]
								@families[key]['LASTUPDATE'] = family.updated
							end
						end
					else
						@families[key]['errors'].push("FAM: #{key} SKIPPED: #{el0[i1][1]}")
					end
				end
				family.save
			elsif el0[2] == 'SOUR'
				key = el0[1]
				@sources[key] = Hash.new
				@sources[key]['errors'] = []
				source = @indexes['SOUR'][key]
				(3..(el0.count - 1)).each do |i1|
					if el0[i1][1] == 'TITL'
						source.title = el0[i1][2]
						@sources[key]['title'] = source.title
					elsif el0[i1][1] == 'ABBR'
						source.abbreviation = el0[i1][2]
						@sources[key]['abbreviation'] = source.abbreviation
					elsif el0[i1][1] == 'PUBL'
						source.published = el0[i1][2]
						@sources[key]['published'] = source.published
					elsif el0[i1][1] == 'REFN'
						source.refn = el0[i1][2]
						@sources[key]['refn'] = source.refn
					elsif el0[i1][1] == 'REPO'
						source.genealogy_repo_id = @indexes['REPO'][el0[i1][2]].id
						@sources[key]['repo'] = source.genealogy_repo_id
					else
						@sources[key]['errors'].push("SOURCE: #{key} SKIPPED: #{el0[i1][1]}")
					end
				end
				source.save
			elsif el0[2] == 'REPO'
				key = el0[1]
				@repos[key] = Hash.new
				@repos[key]['errors'] = []
				repo = @indexes['REPO'][key]
				(3..(el0.count - 1)).each do |i1|
					if el0[i1][1] == 'NAME'
						repo.name = el0[i1][2]
						@repos[key]['name'] = repo.name
					elsif el0[i1][1] == 'ADDR'
						repo.addr = el0[i1][2]
						@repos[key]['addr'] = repo.addr
						(3..(el0[i1].count - 1)).each do |i2|
							if el0[i1][i2][1] == 'CITY'
								repo.city = el0[i1][2]
								@repos[key]['city'] = repo.city
							elsif el0[i1][i2][1] == 'STAE'
								repo.state = el0[i1][2]
								@repos[key]['state'] = repo.state
							elsif el0[i1][i2][1] == 'CTRY'
								repo.country = el0[i1][2]
								@repos[key]['country'] = repo.country
							else
								@repos[key]['errors'].push("REPO ADDR: #{key} SKIPPED: #{el0[i1][1]}")
							end
						end
					else
						@repos[key]['errors'].push("REPO: #{key} SKIPPED: #{el0[i1][1]}")
					end
				end
				repo.save
			end
		end
		redirect_to new_health_import_path(messages: @messages.to_json)
	end

	private

	def require_genealogy_admin
		unless current_user_role('genealogy_admin')
			redirect_to root_url, alert: "Inadequate permissions: Genealogy Admin Bulk Input"
		end
	end

end
