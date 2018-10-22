require 'rails_helper'

def parsed_body
  JSON.parse response.body
end

RSpec.describe 'Foo API', type: :request do
  include_context 'db_cleanup_each', :transaction

  context 'caller requests all Foo' do
    it_should_behave_like 'all resource', :foo do
      let(:response_check) do
        expect(payload.count).to eq resources.count
        expect(payload.map { |e| e['name'] }).to eq(resources.map { |e| e[:name] }) # No sort/paginate
      end
    end
  end
  
  context 'specific Foo' do
    it_should_behave_like 'specific resource', :foo do
      let(:response_check) do
        expect(payload).to have_key 'id'
        expect(payload).to have_key 'name'
        expect(payload['id']).to eq(resource.id)
        expect(payload['name']).to eq resource.name
      end

      let(:error_check) do
        expect(payload).to have_key 'errors'
        expect(payload['errors']).to have_key 'full_messages'
        expect(payload['errors']['full_messages'][0]).to include 'cannot', bad_id.to_s
      end
    end
  end

  context 'caller create a new Foo' do
    it_should_behave_like 'create a new resource', :foo do
      let(:check_data) do
        foo = Foo.where(name: resource_attr[:name]).first
        expect(foo).to_not be_nil
        expect(foo).to respond_to :name, :name=
        expect(foo.name).to eq resource_attr[:name]
      end
    end
    
  end

  context 'existing Foo' do
    it_should_behave_like 'existing resource', :foo do
      let(:pre_check) do
        expect(resource.name).to_not eq new_state[:name] # Verify false-positive
      end

      let(:post_check) do
        expect(Foo.find(resource.id).name).to eq new_state[:name]
      end
    end
  end
end
