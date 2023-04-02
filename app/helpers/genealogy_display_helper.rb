module GenealogyDisplayHelper

    def display(individual, type)
		grid = []
		GenealogyInfo.where("genealogy_individual_id = ? AND itype = ?", individual.id, type).each do |info|
			if type == 'name'
				t = "#{info.data['given']} #{info.data['surname']} #{info.data['suffix']}"
			else
				t = "DATE:#{info.date} PLACE:#{info.place}"
			end
			if info.note
				t = t + "NOTE:#{info.note}"
			end
			if type == 'event'
				t = t + ' ' + "TYPE:#{info.data['type']} NOTE:#{info.data['note']}"
			end
			grid.push(t)
			ind = grid.count - 1
			GenealogyInfoSource.where("genealogy_info_id = ?", info.id).each do |bs|
				source = GenealogySource.find(bs.genealogy_source_id)
				tmp = "SOURCE:#{source.title} (#{source.abbreviation}) PUBLISHED: #{source.published} REFN:#{source.refn}"
				if source.genealogy_repo_id && source.genealogy_repo_id > 0
					repo = GenealogyRepo.find(source.genealogy_repo_id)
					tmp = "#{tmp}: REPO: #{repo.name} LOCATION: #{repo.addr}, #{repo.city}, #{repo.state} #{repo.country}"
				end
				if ! bs.page.blank?
					tmp = "#{tmp} PAGE:#{bs.page}"
				end
				if ! bs.quay.blank?
					tmp = "#{tmp} QUAY:#{bs.page}"
				end
				if ! bs.note.blank?
					tmp = "#{tmp} NOTE:#{bs.page}"
				end
				grid[ind] = "#{grid[ind]} #{tmp}"
			end
		end
		return(grid)
	end

end
