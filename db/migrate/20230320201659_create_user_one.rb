class CreateUserOne < ActiveRecord::Migration[7.0]
  def change
  	user = User.new
	user.email = 'asa.romberger@gmail.com'
	user.password = 'bar.hal42'
	user.password_confirmation = 'bar.hal2'
	user.save
  end
end
