class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.references :user
      t.string :title
      t.string :cd_image_url
      t.string :artist
      t.string :album
      t.string :sample
      t.timestamps null: false
    end
  end
end
