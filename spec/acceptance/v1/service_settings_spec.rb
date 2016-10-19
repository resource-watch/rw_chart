require 'acceptance_helper'

module V1
  describe 'Create Service Settings', type: :request do
    context 'For none existing settings' do
      it 'Allows to register service' do
        get "/info"

        expect(status).to eq(200)
      end
    end
  end
end
