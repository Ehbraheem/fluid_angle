require 'rails_helper'

RSpec.describe Contact, type: :model do
  include_context 'db_cleanup_each'
  let(:user) { FactoryGirl.create :user }

  context 'Existing object' do
    # let!(:contacts) { FactoryGirl.create_list :contact, 2, :with_static_phone, user_id: user.id }
    # let!(:contacts) { 3.times.map { |e| FactoryGirl.create :contact, user: user } }
    let!(:contacts) { FactoryGirl.create_list :contact, 2, user_id: user.id }

    it 'more than one object' do
      expect(Contact.count).to be > 1
      expect(Contact.all).to respond_to :count && :length # Array Duck-Type
      expect(Contact.all.size).to eq contacts.length
    end
    
    it 'return all object' do
      expect(Contact.count).to eq contacts.length
    end
  end

  context 'valid with valid attributes' do
    let(:contact) { FactoryGirl.build :contact, user: user }
    it 'verify valid object' do
      expect(contact).to be_valid
    end

    it 'save valid object' do
      expect(contact.save).to be true
    end

    it 'verify persistence' do
      contact.save
      expect(contact).to be_persisted
    end
  end

  context 'invalid with invalid attributes' do
    let(:contact) { FactoryGirl.build :contact, :invalid, user: user }

    it 'verify invalid object' do
      expect(contact).to_not be_valid
    end

    it 'fail to save invalid object' do
      expect(contact.save).to be false
    end

    it 'verify not persistence' do
      expect(contact).to_not be_persisted
    end
  end

  context 'CRUD' do
    # let!(:contacts) { FactoryGirl.create_list :contact, 2, :with_static_phone, user: user }
    # let!(:contacts) { 3.times.map { |e| FactoryGirl.create :contact, user: user } }
    let!(:contacts) { FactoryGirl.create_list :contact, 2, user_id: user.id }
    let(:contact) { FactoryGirl.attributes_for :contact, user: user }

    it 'can create valid contact' do
      obj = Contact.create contact
      expect(obj).to be_persisted
    end

    it 'update existing object' do
      obj = Contact.first
      expect(obj.update_attributes(contact)).to be true
    end

    it 'can read existing object' do
      obj = Contact.first
      expect(Contact.all).to_not be_empty
      expect(Contact.find(obj.id)).to be_a_kind_of Contact
    end

    it 'can delete valid object' do
      obj = Contact.first
      expect(Contact.find(obj.id)).to be_a_kind_of Contact
      Contact.destroy(obj.id)
      expect { Contact.find(obj.id) }.to raise_exception ActiveRecord::RecordNotFound
    end
  end

  context 'Validations' do
    it 'cannot create object with invalid phone_number' do
      obj = FactoryGirl.build :contact, user: user, phone_number: nil
      expect(obj).to_not be_valid
      expect(obj.save).to eq false
      # byebug
      expect(obj).to respond_to :errors
      expect(obj.errors).to respond_to :messages
      expect(obj.errors.messages).to include /phone_number/
      expect(obj.errors.messages).to have_key :phone_number
      expect(obj.errors.messages[:phone_number]).to include /can\'t be blank/
    end

    it 'cannot create object with existing phone_number' do
      contact = FactoryGirl.build :contact, user: user
      expect(contact).to be_valid
      expect(contact.save).to eq true
      expect(contact).to be_persisted

      # build Another object with same phone_number
      bad_contact = FactoryGirl.build :contact, phone_number: contact.phone_number
      expect(bad_contact).to_not be_valid
      expect(bad_contact.save).to eq false
      expect(bad_contact).to_not be_persisted

      expect(bad_contact).to respond_to :errors
      expect(bad_contact.errors).to respond_to :messages
      expect(bad_contact.errors.messages).to include /phone_number/
      expect(bad_contact.errors.messages).to have_key :phone_number
      expect(bad_contact.errors.messages[:phone_number]).to include /has already been taken/
    end
  end
end
