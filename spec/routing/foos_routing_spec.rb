require 'rails_helper'

RSpec.describe FoosController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: foos_path).to route_to('foos#index', format: :json)
    end

    it 'routes to #show' do
      expect(get: foo_path(1)).to route_to('foos#show', id: '1', format: :json)
    end


    it 'routes to #create' do
      expect(post: foos_path).to route_to('foos#create', format: :json)
    end

    it 'routes to #update via PUT' do
      expect(put: foo_path(1)).to route_to('foos#update', id: '1', format: :json)
    end

    it 'routes to #update via PATCH' do
      expect(patch: foo_path(1)).to route_to('foos#update', id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: foo_path(1)).to route_to('foos#destroy', id: '1', format: :json)
    end
  end
end
