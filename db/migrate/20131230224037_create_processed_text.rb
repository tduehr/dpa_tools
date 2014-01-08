class CreateProcessedText < ActiveRecord::Migration
  def change
    create_table :processed_texts do |t|
      t.references :trace, index: true
      t.references :user, index: true
      t.string :comment
      t.binary :content
      t.timestamps
    end
    add_index :processed_texts, :comment
    add_index :processed_texts, :content
  end
end
