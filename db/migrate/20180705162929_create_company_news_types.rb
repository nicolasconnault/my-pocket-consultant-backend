class CreateCompanyNewsTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :company_news_types do |t|
      t.references :news_type, foreign_key: true
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
