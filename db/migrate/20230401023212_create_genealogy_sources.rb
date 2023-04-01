class CreateGenealogySources < ActiveRecord::Migration[7.0]
  def change
    create_table :genealogy_sources do |t|
      t.string :title
      t.string :abbreviation
      t.string :published
      t.string :refn
      t.integer :genealogy_repo_id

      t.timestamps
    end
  end
end
