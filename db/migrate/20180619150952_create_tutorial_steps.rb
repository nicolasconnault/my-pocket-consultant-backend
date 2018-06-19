class CreateTutorialSteps < ActiveRecord::Migration[5.0]
  def change
    create_table :tutorial_steps do |t|
      t.references :company_tutorial, foreign_key: true
      t.string :title, null: false
      t.string :description, null: false
      t.integer :sort_order, default: 1
      t.boolean :video, default: false

      t.timestamps
    end
  end
end
