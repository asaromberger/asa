class UserOneAdmin < ActiveRecord::Migration[7.0]
  def change
  	perm = Permission.new
	perm.user_id = 1
	perm.pkey = 'siteadmin'
	perm.pvalue = {}
	perm.save
  end
end
