class CreateDataFile < ActiveRecord::Migration
  def change
    create_table :data_files do |t|
      t.string :name
      t.string :ftype
      t.string :source
      t.binary :data
      t.timestamps
      t.references :trace
    end
    add_index :data_files, :name
    add_index :data_files, [:trace_id, :ftype], unique: true
    add_index :data_files, [:trace_id, :source], unique: true
    add_index :data_files, [:trace_id, :ftype, :source], unique: true
    
    remove_column :traces, :chan1_data, :binary
    remove_column :traces, :chan2_data, :binary
    remove_column :traces, :digital_data, :binary
  end
end
