class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.integer :post_id
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
