class AddVerifiedAndLayerIdToCharts < ActiveRecord::Migration[5.0]
  def change
    add_column :charts, :verified,   :boolean, default: false, index: true
    add_column :charts, :layer_id,   :uuid
    add_column :charts, :dataset_id, :uuid
  end
end
