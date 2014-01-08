class CreateImplementation < ActiveRecord::Migration
  def change
    create_table :implementations do |t|
      t.string :name
      t.string :algorithm
      t.integer :traces_count
      t.timestamps
    end
    add_index :implementations, :name
    add_index :implementations, :algorithm
  end
end
