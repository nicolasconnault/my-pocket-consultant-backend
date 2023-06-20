class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :label
      t.references :company_category, foreign_key: true
      t.timestamps
    end
  end
end
