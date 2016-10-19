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

require 'rails_helper'

RSpec.describe Chart, type: :model do
  let!(:chart_config) {{"marks": {
                  "type": "rect",
                  "from": {
                    "data": "table"
                  }}}}

  let!(:charts) {
    charts = []
    charts << Chart.create!(name: 'Chart data',     status: 1, published: true, slug: 'first-test-chart', chart_config: chart_config, application: ['prep', 'gfw'])
    charts << Chart.create!(name: 'Chart data two', description: 'Lorem ipsum...', application: ['wrw'])
    charts << Chart.create!(name: 'Chart data one', status: 1, application: ['GFW'], published: true)
    charts.each(&:reload)
  }

  let!(:chart_first)  { charts[0] }
  let!(:chart_second) { charts[1] }
  let!(:chart_third)  { charts[2] }

  it 'Is valid' do
    expect(chart_first).to                be_valid
    expect(chart_first.slug).to           eq('first-test-chart')
    expect(chart_first.chart_config).to          be_present
  end

  it 'Generate slug after create' do
    expect(chart_third.slug).to eq('chart-data-one')
  end

  it 'Do not allow to create chart without name' do
    chart_reject = Chart.new(name: '', slug: 'test')

    chart_reject.valid?
    expect {chart_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
  end

  it 'Do not allow to create chart with wrong slug' do
    chart_reject = Chart.new(name: 'test', slug: 'test&')

    chart_reject.valid?
    expect {chart_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Slug invalid. Slug must contain at least one letter and no special character")
  end

  it 'Do not allow to create chart with name douplications' do
    expect(chart_first).to be_valid
    chart_reject = Chart.new(name: 'Chart data', slug: 'test')

    chart_reject.valid?
    expect {chart_reject.save!}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
end
