class CreateSamplePoint < ActiveRecord::Migration
  def change
    create_table :sample_points do |t|
      t.references :trace, index: true
      t.float :timestamp
      t.float :reading
    end
    add_index :sample_points, [:timestamp, :trace_id], unique: true
  end
end
