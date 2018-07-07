class CreateUsersCompanyNewsTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :users_company_news_types do |t|
      t.references :news_type, foreign_key: true
      t.references :users_company, foreign_key: true

      t.timestamps
    end
  end
end
