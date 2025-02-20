class CreateRelationships < ActiveRecord::Migration[6.1]
  def change
    create_table :relationships do |t|
      t.references :user, foreign_key: true
      t.references :follow, foreign_key: { to_table: :users }
     
      t.timestamps null: false
     
      t.index [:user_id, :follow_id], unique: true
    end
  end
end
