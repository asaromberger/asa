class AddApplicationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :application, :string
  end
end
