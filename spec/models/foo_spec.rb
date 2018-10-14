require 'rails_helper'

RSpec.describe Foo, type: :model do
  include_context 'db_cleanup_each'

  context 'Existing object' do
    let!(:foos) { FactoryGirl.create_list :foo, 10 }

    it 'more than one object' do
      expect(Foo.count).to be > 1
      expect(Foo.all).to respond_to :count && :length # Array Duck-Type
      expect(Foo.all.size).to eq foos.length
    end
    
    it 'return all object' do
      expect(Foo.count).to eq foos.length
    end
  end

  context 'valid with valid attributes' do
    let(:foo) { FactoryGirl.build :foo }
    it 'verify valid object' do
      expect(foo).to be_valid
    end

    it 'save valid object' do
      expect(foo.save).to be true
    end

    it 'verify persistence' do
      foo.save
      expect(foo).to be_persisted
    end
  end

  context 'invalid with invalid attributes' do
    let(:foo) { FactoryGirl.build :foo, name: nil }

    it 'verify invalid object' do
      expect(foo).to_not be_valid
    end

    it 'fail to save invalid object' do
      expect(foo.save).to be false
    end

    it 'verify not persistence' do
      expect(foo).to_not be_persisted
    end
  end

  context 'CRUD' do
    let!(:foos) { FactoryGirl.create_list :foo, 10 }
    let(:foo) { FactoryGirl.attributes_for :foo }

    it 'can create valid foo' do
      obj = Foo.create foo
      expect(obj).to be_persisted
    end

    it 'update existing object' do
      obj = Foo.first
      expect(obj.update_attributes(foo)).to be true
    end

    it 'can read existing object' do
      obj = Foo.first
      expect(Foo.all).to_not be_empty
      expect(Foo.find(obj.id)).to be_a_kind_of Foo
    end

    it 'can delete valid object' do
      obj = Foo.first
      expect(Foo.find(obj.id)).to be_a_kind_of Foo
      Foo.destroy(obj.id)
      expect { Foo.find(obj.id) }.to raise_exception ActiveRecord::RecordNotFound
    end
  end
end
