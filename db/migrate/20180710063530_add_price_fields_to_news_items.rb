class AddPriceFieldsToNewsItems < ActiveRecord::Migration[5.0]
  def change
    add_column :news_items, :discountedPrice, :float
    add_column :news_items, :regularPrice, :float
  end
end
