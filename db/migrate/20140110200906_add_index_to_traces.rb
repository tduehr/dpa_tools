class AddIndexToTraces < ActiveRecord::Migration
  def change
    add_index :traces, :plain_text
    add_index :traces, :cipher_text
    add_index :traces, :key
  end
end
