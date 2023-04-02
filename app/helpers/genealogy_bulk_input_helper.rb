module GenealogyBulkInputHelper

    def bicollect(individual, type, data, individuals, indexes)
		uctype = type.upcase
		info = GenealogyInfo.new
		info.itype = type
		info.genealogy_individual_id = individual.id
		info.save
		if type == 'name'
			t = data[2]
			individuals['GIVN'] = data[2].gsub(/\s*\/.*/, '')
			individuals['SURN'] = data[2].gsub(/^[^\/]*\/\s*/, '').gsub(/\s*\/.*/, '')
		end
		(3..(data.count - 1)).each do |i2|
			if data[i2][1] == 'DATE'
				individuals['#{uctype}DATE'] = data[i2][2]
			elsif data[i2][1] == 'PLAC'
				individuals['#{uctype}PLACE'] = data[i2][2]
			elsif data[i2][1] == 'GIVN'
				individuals['GIVN'] = data[i2][2]
			elsif data[i2][1] == 'SURN'
				individuals['SURN'] = data[i2][2]
			elsif data[i2][1] == 'NSFX'
				individuals['NSFX'] = data[i2][2]
			elsif data[i2][1] == 'TYPE'
				individuals['#{uctype}TYPE'] = data[i2][2]
			elsif data[i2][1] == 'NOTE'
				if data[i2][2].match(/^@.*@/)
					individuals['#{uctype}NOTE'] = @indexes['NOTE'][data[i2][2]]
				else
					individuals['#{uctype}NOTE'] = data[i2][2]
				end
			elsif data[i2][1] == 'SOUR'
				is = GenealogyInfoSource.new
				is.genealogy_info_id = info.id
				page = ''
				quay = ''
				note = ''
				(3..(data[i2].count - 1)).each do |i3|
					if data[i2][i3][1] == 'PAGE'
						page = data[i2][i3][2]
					elsif data[i2][i3][1] == 'QUAY'
						quay = data[i2][i3][2]
					elsif data[i2][i3][1] == 'NOTE'
						note = data[i2][i3][2]
					else
						individuals['errors'].push("${uctype} SOURCE: #{individual['GIVN']} #{individual['SURN']}: SKIPPED: #{data[i2][1]}:#{data[i2][i3][1]}")
					end
				end
				is.genealogy_source_id = indexes[data[i2][2]].id
				is.page = page
				is.quay = quay
				is.note = note
				is.save
			else
				individuals['errors'].push("DEATH: #{individuals['GIVN']} #{individuals['SURN']}: SKIPPED: #{data[i2][1]}")
			end
		end
		if type == 'name'
			info.data = {
				given: individuals['GIVN'] || '',
				surname: individuals['SURN'] || '',
				suffix: individuals['NSFX'] || ''
			}
		elsif type == 'event'
			info.data = {
				type: individuals['EVENTTYPE'],
				note: individuals['EVENTNOTE'],
			}
		end
		info.date = individuals['#{uctype}DATE']
		info.place = individuals['#{uctype}PLACE']
		info.note = individuals['#{uctype}NOTE']
		info.save
	end

end
