require 'rails_helper'

def attr_check(payload, resource)
  attrs.each do |attr|
    expect(payload).to have_key attr.to_s
    expect(payload[attr.to_s]).to eq resource[attr]
  end
end

def attrs
  %i(first_name last_name email phone_number star)
end

RSpec.describe 'Contacts', type: :request do
  include_context 'db_cleanup_each', :transaction

  context 'caller requests all Contact' do
    it_should_behave_like 'all resource', [:contact, :user] do
      let(:response_check) do
        expect(payload.count).to eq resources.count
        attrs.each do |attr|  
          expect(payload.map { |e| e[attr.to_s] }).to match_array(resources.map { |e| e[attr] }) # No sort/paginate
        end
      end
    end
  end
  
  context 'specific Contact' do
    it_should_behave_like 'specific resource', [:contact, :user] do
      let(:response_check) do
        # expect(payload).to have_key 'id'
        # expect(payload).to have_key 'first_name'
        # expect(payload['id']).to eq(resource.id)
        # expect(payload['first_name']).to eq resource.first_name
        attr_check payload, resource
      end

      let(:error_check) do
        expect(payload).to have_key 'errors'
        expect(payload['errors']).to have_key 'full_messages'
        expect(payload['errors']['full_messages'][0]).to include 'cannot', bad_id.to_s
      end
    end
  end

  context 'caller create a new Contact' do
    it_should_behave_like 'create a new resource', [:contact, :user] do
      let(:check_data) do
        contact = Contact.where(first_name: resource_attr[:first_name]).first
        expect(contact).to_not be_nil
        
        attrs.each do |e| 
          expect(contact).to respond_to e, "#{e}=" 
        end
      end
    end
    
  end

  context 'existing Contact' do
    it_should_behave_like 'existing resource', [:contact, :user] do
      let(:pre_check) do
        expect(resource.first_name).to_not eq new_state[:first_name] # Verify false-positive
      end

      let(:post_check) do
        expect(Contact.find(resource.id).first_name).to eq new_state[:first_name]
      end
    end
  end

  context 'starred Contacts' do
    let(:account) { signup user_attr, :ok }
    let!(:user) { login account, :ok }
    let!(:resources) { FactoryBot.create_list :contact, 20, user_id: user['id'] }

    it 'returns starred Contacts' do
      jget contacts_stars_path
      expect(response).to have_http_status :ok

      payload = parsed_body
      # byebug
      # expect(payload.map { |e| e['star'] }.all? { |e| e }).to be true
      expect(payload.map { |e| e['star'] }.all?(true)).to be true
    end

    it 'does not return contacts that are not starred' do
      jget contacts_stars_path
      expect(response).to have_http_status :ok

      payload = parsed_body
      # byebug
      expect(payload.map { |e| e['star'] }.any?(false)).to be false
    end
  end

  context 'modify starred contact' do
    let(:account) { signup user_attr, :ok }
    let!(:user) { login account, :ok }
    let!(:resources) { FactoryBot.create_list :contact, 20, user_id: user['id'] }
    let(:contact) { Contact.where(star: false).last }

    it 'modify contact star without error' do
      jput contact_star_path(contact.id), star: true
      expect(response).to have_http_status :ok

      expect(parsed_body).to_not have_key 'errors'
    end

    it 'verify contact is modified' do
      jget contact_path(contact.id)
      # byebug
      expect(response).to have_http_status :ok
      expect(parsed_body['star']).to eq false

      jput contact_star_path(contact.id), star: true
      expect(response).to have_http_status :ok
      expect(parsed_body['star']).to eq true
    end

    it 'verify contact star persist to index route' do
      jput contact_star_path(contact.id), star: true
      expect(response).to have_http_status :ok

      jget contacts_path
      expect(response).to have_http_status :ok

      payload = parsed_body
      # byebug
      contact.reload
      expect(payload.any? { |e| e['id'] == contact.id && e['star'] == contact.star }).to eq true
    end
  end
end
