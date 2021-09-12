class AddComment < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :comment, :string
  end
end
