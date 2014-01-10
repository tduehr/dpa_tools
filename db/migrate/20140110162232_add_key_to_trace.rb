class AddKeyToTrace < ActiveRecord::Migration
  def change
    add_column :traces, :key, :text
  end
end
