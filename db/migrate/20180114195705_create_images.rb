class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :filename
      t.integer :height
      t.integer :width

      t.timestamps
    end
  end
end
