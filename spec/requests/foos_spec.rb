require 'rails_helper'

def parsed_body
  JSON.parse response.body
end

RSpec.describe 'Foo API', type: :request do
  include_context 'db_cleanup_each'

  context 'caller requests all Foos' do
    let!(:foos) { (1..5).map { |e| FactoryGirl.create :foo } }

    it 'check request/response' do
      get foos_path, headers: { 'Accept' => 'application/json' }
      expect(request.method).to eq 'GET'
      expect(response).to have_http_status :ok
      expect(response.content_type).to eq 'application/json'
      expect(response['X-Frame-Options']).to eq 'SAMEORIGIN'
    end

    it 'returns all instance' do
      get foos_path, headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status :ok
      payload = parsed_body
      expect(payload.count).to eq foos.count
      expect(payload.map { |e| e['name'] }).to eq(foos.map { |e| e[:name] }) # No sort/paginate
    end
  end

  context 'caller request specific Foo' do
    let(:foo) { FactoryGirl.create :foo }
    let(:bad_id) { 4_556_645 }

    it 'returns Foo when given correct ID' do
      get foo_path(foo.id)
      expect(response).to have_http_status :ok

      payload = parsed_body
      expect(payload).to have_key 'id'
      expect(payload).to have_key 'name'
      expect(payload['id']).to eq(foo.id)
      expect(payload['name']).to eq foo.name
    end

    it 'returns not found using incorrect ID' do
      get foo_path(bad_id)
      expect(response).to have_http_status :not_found
      expect(response.content_type).to eq 'application/json'

      payload = parsed_body
      expect(payload).to have_key 'errors'
      expect(payload['errors']).to have_key 'full_messages'
      expect(payload['errors']['full_messages']).to include %W(cannot #{bad_id})
    end
    
  end

  context 'caller create a new Foo' do
    let(:foo_attr) { FactoryGirl.attributes_for :foo }

    it 'can create Foo with provided name' do
      post foos_path, params: foo_attr
      expect(response).to have_http_status :created
      expect(response.content_type).to eq 'application/json'
    end
    
  end

  context 'existing Foo' do
    let(:foo) { FactoryGirl.create :foo }
    let(:new_name) { 'tested' }

    it 'can be updated from API endpoint' do
      expect(foo.name).to_not eq new_name # Verify false-positive
      put foo_path(foo.id), params: { name: new_name }
      expect(response).to have_http_status :no_content
      expect(Foo.find(foo.id).name).to eq new_name
    end

    it 'can be deleted from API endpoint' do
      head foo_path(foo.id)
      expect(response).to have_http_status :ok

      delete foo_path(foo.id)
      expect(response).to have_http_status :no_content

      head foo_path(foo.id)
      expect(response).to have_http_status :not_found
    end
  end
end
