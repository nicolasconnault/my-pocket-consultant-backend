class CreateCompanyTutorials < ActiveRecord::Migration[5.0]
  def change
    create_table :company_tutorials do |t|
      t.references :company, foreign_key: true
      t.references :tutorial_category, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end
  end
end
