class AddSourceUrlToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :source_url, :string
  end
end
