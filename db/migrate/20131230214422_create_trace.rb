class CreateTrace < ActiveRecord::Migration
  def change
    create_table :traces do |t|
      t.string :trace_type
      t.references :implementation, index: true
      t.integer :sample_points_count
      t.string :plain_text
      t.string :cipher_text
      t.float :time_scale
      t.float :time_offset
      t.float :chan1_scale
      t.float :chan1_offset
      t.binary :chan1_data
      t.float :chan2_scale
      t.float :chan2_offset
      t.binary :chan2_data
      t.binary :digital_data
      t.integer :digital_source
      t.integer :digital_position
      t.float :sampling_rate
      t.integer :resistor
      t.timestamps
    end
  end
end
