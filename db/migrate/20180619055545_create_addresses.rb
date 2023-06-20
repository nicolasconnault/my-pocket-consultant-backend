class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :country, foreign_key: true
      t.references :user, foreign_key: true
      t.string :street1
      t.string :street2
      t.string :unit
      t.string :suburb
      t.float :latitude
      t.float :longitude
      t.string :phone
      t.string :fax
      t.string :state
      t.string :postcode
      t.string :timezone
      t.timestamps
    end
  end
end
