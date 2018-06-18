class AddEnabledToUsersCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :users_companies, :enabled, :boolean, default: true
  end
end
