class RenameChartToChartConfig < ActiveRecord::Migration[5.0]
  def change
    rename_column :charts, :chart, :chart_config
  end
end
