class AddNewAttributesToCharts < ActiveRecord::Migration[5.0]
  def change
    add_column :charts, :template, :boolean, default: false
    add_column :charts, :default, :boolean, default: false
    add_column :charts, :application, :jsonb, default: []
  end
end
