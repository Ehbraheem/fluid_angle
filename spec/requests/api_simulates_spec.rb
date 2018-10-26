require 'rails_helper'

def parsed_body
  JSON.parse response.body
end

RSpec.describe 'ApiSimulates', type: :request do
  include_context 'db_cleanup_each'

  describe 'Database-backed' do
    it 'create Database-backed model' do
      object = Foo.create name: 'test'
      expect(Foo.find(object.id).name).to eq 'test'
    end

    it 'expose Database-backed API resource' do
      object = Foo.create name: 'test'
      expect(foos_path).to eq '/api/foos'
      get foo_path(object.id)
      expect(response).to have_http_status :ok
      expect(parsed_body['name']).to eq 'test'
    end
  end
end
