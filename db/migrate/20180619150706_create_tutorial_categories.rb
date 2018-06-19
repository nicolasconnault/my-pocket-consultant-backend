class CreateTutorialCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :tutorial_categories do |t|
      t.references :company_category, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end
  end
end
