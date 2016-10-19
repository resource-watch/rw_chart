# frozen_string_literal: true
# == Schema Information
#
# Table name: charts
#
#  id           :uuid             not null, primary key
#  name         :string           not null
#  slug         :string
#  description  :text
#  source       :string
#  source_url   :string
#  authors      :string
#  query_url    :string
#  chart_config :jsonb
#  status       :integer          default(0)
#  published    :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  verified     :boolean          default(FALSE)
#  layer_id     :uuid
#  dataset_id   :uuid
#  template     :boolean          default(FALSE)
#  default      :boolean          default(FALSE)
#  application  :jsonb
#

class ChartSerializer < ActiveModel::Serializer
  attributes :id, :application, :slug, :name, :description, :source, :source_url,
             :layer_id, :dataset_id, :authors, :query_url, :chart_config, :template, :default

  def chart_config
    object.chart_config == '{}' ? nil : object.chart_config
  end
end
