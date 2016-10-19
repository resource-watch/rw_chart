require 'acceptance_helper'

module V1
  describe 'Charts', type: :request do
    context 'Create, update and delete charts' do
      let!(:settings) {{"marks": {
                        "type": "rect",
                        "from": {
                          "data": "table"
                      }}}}

      let!(:chart_config) {{"marks": {
                            "type": "rect",
                            "from": {
                              "data": "table"
                            }}}}

      let!(:params) {{"chart": { "name": "First test chart", "chartConfig": "#{chart_config}" }}}

      let!(:params_faild) {{"chart": { "name": "Chart second one" }}}

      let!(:chart) {
        Chart.create!(name: 'Chart second one', application: ['gfw'])
      }

      let!(:chart_id)   { chart.id   }
      let!(:chart_slug) { chart.slug }

      let!(:update_params) {{"chart": { "name": "First test one update",
                                        "slug": "updated-first-test-chart" }
                           }}

      context 'List filters' do
        let!(:disabled_chart) {
          Chart.create!(name: 'Chart second second', slug: 'chart-second-second', status: 3, published: false)
        }

        let!(:enabled_chart) {
          Chart.create!(name: 'Chart one', status: 1, published: true, verified: true, application: ['Gfw', 'wrw'], dataset_id: 'c547146d-de0c-47ff-a406-5125667fd5e6', default: true)
        }

        let!(:enabled_chart_2) {
          Chart.create!(name: 'Chart one two', status: 1, published: true, verified: true, application: ['Gfw'], dataset_id: 'c547146d-de0c-47ff-a406-5125667fd5e7', template: true)
        }

        let!(:unpublished_chart) {
          Chart.create!(name: 'Chart one unpublished', status: 1, published: false, verified: true)
        }

        it 'Show list of all charts' do
          get '/chart?status=all'

          expect(status).to    eq(200)
          expect(json.size).to eq(5)
        end

        it 'Show list of charts with pending status' do
          get '/chart?status=pending'

          expect(status).to    eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of charts with active status' do
          get '/chart?status=active'

          expect(status).to    eq(200)
          expect(json.size).to eq(2)
        end

        it 'Show list of charts with disabled status' do
          get '/chart?status=disabled'

          expect(status).to    eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show list of charts with published status true' do
          get '/chart?published=true'

          expect(status).to eq(200)
          expect(json.size).to                          eq(2)
          expect(json[0]['attributes']['published']).to eq(true)
        end

        it 'Show list of charts with published status false' do
          get '/chart?published=false'

          expect(status).to eq(200)
          expect(json.size).to                          eq(3)
          expect(json[0]['attributes']['published']).to eq(false)
        end

        it 'Show list of charts with verified status false' do
          get '/chart?verified=false'

          expect(status).to eq(200)
          expect(json.size).to                         eq(2)
          expect(json[0]['attributes']['verified']).to eq(false)
        end

        it 'Show list of charts with verified status true' do
          get '/chart?verified=true'

          expect(status).to eq(200)
          expect(json.size).to                         eq(3)
          expect(json[0]['attributes']['verified']).to eq(true)
        end

        it 'Show list of charts for app GFW' do
          get '/chart?app=GFw'

          expect(status).to eq(200)
          expect(json.size).to eq(2)
        end

        it 'Show list of charts for app WRW' do
          get '/chart?app=wrw'

          expect(status).to eq(200)
          expect(json.size).to eq(1)
        end

        it 'Show blank list of charts for not existing app' do
          get '/chart?app=notexisting'

          expect(status).to eq(200)
          expect(json.size).to eq(0)
        end

        it 'Show blank list of charts for not existing app' do
          get '/chart?app=all'

          expect(status).to eq(200)
          expect(json.size).to eq(2)
        end

        it 'Show list of charts with template true' do
          get '/chart?template=true'

          expect(status).to eq(200)
          expect(json.size).to                         eq(1)
          expect(json[0]['attributes']['template']).to eq(true)
        end

        it 'Show list of charts with default true' do
          get '/chart?default=true'

          expect(status).to eq(200)
          expect(json.size).to                        eq(1)
          expect(json[0]['attributes']['default']).to eq(true)
        end

        it 'Show list of charts with default false' do
          get '/chart?default=false'

          expect(status).to eq(200)
          expect(json.size).to                        eq(1)
          expect(json[0]['attributes']['default']).to eq(false)
        end

        it 'Show list of charts for a specific dataset' do
          get '/chart?dataset=c547146d-de0c-47ff-a406-5125667fd5e7'

          expect(status).to eq(200)
          expect(json.size).to                           eq(1)
          expect(json[0]['attributes']['datasetId']).to eq('c547146d-de0c-47ff-a406-5125667fd5e7')
        end

        it 'Show blank list of charts for a non existing dataset' do
          get '/chart?dataset=c547146d-de0c-47ff-a406-5125667fd5e9'

          expect(status).to eq(200)
          expect(json.size).to eq(0)
        end

        it 'Show list of charts' do
          get '/chart'

          expect(status).to    eq(200)
          expect(json.size).to eq(2)
        end
      end

      it 'Show chart by slug' do
        get "/chart/#{chart_slug}"

        expect(status).to eq(200)
        expect(json['attributes']['slug']).to  eq('chart-second-one')
        expect(json_main['meta']['status']).to eq('pending')
      end

      it 'Show chart by id' do
        get "/chart/#{chart_id}"

        expect(status).to eq(200)
      end

      it 'Allows to create second chart' do
        post '/chart', params: params

        expect(status).to eq(201)
        expect(json['id']).to                        be_present
        expect(json['attributes']['slug']).to        eq('first-test-chart')
        expect(json['attributes']['chartConfig']).to be_present
      end

      it 'Name and slug validation' do
        post '/chart', params: params_faild

        expect(status).to eq(422)
        expect(json_main['message']['name']).to eq(['has already been taken'])
        expect(json_main['message']['slug']).to eq(['has already been taken'])
      end

      it 'Allows to update chart' do
        put "/chart/#{chart_slug}", params: update_params

        expect(status).to eq(200)
        expect(json['id']).to                 be_present
        expect(json['attributes']['name']).to eq('First test one update')
        expect(json['attributes']['slug']).to eq('updated-first-test-chart')
      end

      it 'Allows to delete chart by id' do
        delete "/chart/#{chart_id}"

        expect(status).to eq(200)
        expect(json_main['message']).to        eq('Chart deleted')
        expect(Chart.where(id: chart_id)).to be_empty
      end

      it 'Allows to delete chart by slug' do
        delete "/chart/#{chart_slug}"

        expect(status).to eq(200)
        expect(json_main['message']).to                 eq('Chart deleted')
        expect(Chart.where(slug: chart_slug)).to be_empty
      end

      context 'Save dataset_id from query' do
        let!(:chart_last) {
          Chart.create!(name: 'Chart last', status: 1, published: true, verified: true, layer_id: 'c547146d-de0c-47ff-a406-5125667fd5e1',
                         query_url: 'http://ec2-52-23-163-254.compute-1.amazonaws.com/query/c547146d-de0c-47ff-a406-5125667fd599?select[]=iso&order[]=-iso')
        }

        let!(:chart_last_id) { chart_last.id }

        it 'Show chart with dataset_id generated from query_url' do
          get "/chart/#{chart_last_id}"

          expect(status).to eq(200)
          expect(json['attributes']['slug']).to      eq('chart-last')
          expect(json['attributes']['layerId']).to   eq('c547146d-de0c-47ff-a406-5125667fd5e1')
          expect(json['attributes']['datasetId']).to eq('c547146d-de0c-47ff-a406-5125667fd599')
          expect(json_main['meta']['verified']).to   eq(true)
        end
      end
    end
  end
end
