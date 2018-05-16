class CreateEmployeeView < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_views do |t|
      t.string :uuid
      t.string :name
      t.string :title
      t.integer :salary
    end
  end
end
