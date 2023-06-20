class CreateUsersCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :users_companies do |t|
      t.references :user, foreign_key: true
      t.references :company, foreign_key: true
      t.references :consultant, foreign_key: { to_table: :users }
      t.boolean :enabled
      t.timestamps
    end
  end
end
