require 'rails_helper'

RSpec.describe Contact, type: :model do
  include_context 'db_cleanup_each'
  # let(:user) { FactoryBot.create :user }

  it_should_behave_like 'Existing object', %i(contact user)

  it_should_behave_like 'valid with valid attributes', %i(contact user)

  it_should_behave_like 'invalid with invalid attributes', %i(contact user)

  it_should_behave_like 'CRUD', %i(contact user)

  it_should_behave_like 'Uniqueness Validation', [:contact, %i(email phone_number), :user]

  context 'Format Validation' do
    let(:user) { FactoryBot.create :user }

    unformated_values = { phone_number: '0700-callmyboss', email: 'm@ck is_agood-lad@gm.com', 
                          first_name: '$$-WOotong', last_name: '##Lagos' }
                          
    %i(first_name last_name email phone_number).each do |attr|
      it "fails validation for wrong #{attr}" do
        contact = FactoryBot.build :contact, user: user, attr => unformated_values[attr]
        # byebug
        expect(contact).to_not be_valid
        expect(contact).to_not be_persisted
        expect(contact.save).to eq false

        error_checker obj: contact, key: attr, msg: 'is invalid'
      end
    end
  end
end
