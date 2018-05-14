class Employee < ActiveRecord::Migration
  def change
    create_table :employee do |t|
      t.text :name
      t.text :title
      t.integer :salary
      t.timestamps
    end
  end
end
