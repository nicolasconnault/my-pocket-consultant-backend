class CreateNewsItems < ActiveRecord::Migration[5.0]
  def change
    create_table :news_items do |t|
      t.references :news_type, foreign_key: true
      t.references :subscription, foreign_key: true
      t.string :title
      t.string :description
      t.date :start_date
      t.date :end_date
      t.boolean :active, default: false
      t.timestamps
    end
  end
end
