module ModelsHelper
  def model_class(type)
    Object.const_get(type.to_s.classify)
  end

  def build_without_trait(model, ancestr = nil, trait = nil)
    params = [trait, ancestr].select { |e| !!(e) }
    # byebug
    params.empty? ? FactoryBot.build(model) : FactoryBot.build(model, *params)
  end

  def build_db_obj(model, ancestr, trait = nil)
    build_without_trait(model, ancestr, trait)
  end

  def create_db_obj(model, ancestr, trait = nil)
    !!(!ancestr) ? FactoryBot.create(model, trait) : FactoryBot.create(model, trait, ancestr)
  end

  def create_db_objs(model, ancestr)
    !!(!ancestr) ? FactoryBot.create_list(model, 10) : FactoryBot.create_list(model, 10, ancestr)
  end

  def create_parent(parent)
    return parent unless parent

    { "#{parent}_id" => create_db_obj(parent, nil).id }
  end

  def error_checker(options = {})
    return if options.empty?

    expect(options[:obj]).to respond_to :errors
    expect(options[:obj].errors).to respond_to :messages
    expect(options[:obj].errors.messages).to include(/#{options[:key]}/)
    expect(options[:obj].errors.messages).to have_key options[:key]
    expect(options[:obj].errors.messages[options[:key]]).to include(/#{options[:msg]}/)
  end  
end

RSpec.shared_examples 'Existing object' do |model, parent = nil| 
  # let!(:objects) { FactoryBot.create_list :object, 2, :with_static_phone, user_id: user.id }
  # let!(:objects) { 3.times.map { |e| FactoryBot.create :object, parent } }
  let(:ancestr) do
    # !!(!parent) || { parent => FactoryBot.create(parent) }
    create_parent parent
  end
  let!(:objects) { create_db_objs model, ancestr }

  it "more than one #{model.to_s.capitalize}" do
    expect(model_class(model).count).to be > 1
    expect(model_class(model).all).to respond_to :count && :length # Array Duck-Type
    expect(model_class(model).all.size).to eq objects.length
  end
  
  it "return all #{model.to_s.capitalize}" do
    expect(model_class(model).count).to eq objects.length
  end
end

RSpec.shared_examples 'valid with valid attributes' do |model, parent = nil|
  let(:ancestr) do
    # !!(!parent) || { parent => FactoryBot.create(parent) }
    create_parent parent
  end

  let(:object) { build_db_obj model, ancestr }

  it "verify valid #{model.to_s.capitalize}" do
    expect(object).to be_valid
  end

  it "save valid #{model.to_s.capitalize}" do
    expect(object.save).to be true
  end

  it 'verify persistence' do
    object.save
    expect(object).to be_persisted
  end
end

RSpec.shared_examples 'invalid with invalid attributes' do |model, parent = nil|
  let(:ancestr) do
    # !!(!parent) || { parent => FactoryBot.create(parent) }
    create_parent parent
  end

  let(:object) { build_db_obj model, ancestr, :invalid }

  it "verify invalid #{model.to_s.capitalize}" do
    expect(object).to_not be_valid
  end

  it "fail to save invalid #{model.to_s.capitalize}" do
    expect(object.save).to be false
  end

  it 'verify not persistence' do
    expect(object).to_not be_persisted
  end
end

RSpec.shared_examples 'CRUD' do |model, parent = nil|
  # let!(:objects) { FactoryBot.create_list :object, 2, :with_static_phone, parent }
  # let!(:objects) { 3.times.map { |e| FactoryBot.create :object, parent } }
  let(:ancestr) do
    # !!(!parent) || { parent => FactoryBot.create(parent) }
    create_parent parent
  end

  let!(:objects) { create_db_objs model, ancestr }
  let(:object) { FactoryBot.attributes_for model, ancestr }

  it "can create valid #{model.to_s.capitalize}" do
    obj = create_db_obj model, ancestr
    expect(obj).to be_persisted
  end

  it "update existing #{model.to_s.capitalize}" do
    obj = model_class(model).first
    expect(obj.update_attributes(object)).to be true
  end

  it "can read existing #{model.to_s.capitalize}" do
    obj = model_class(model).first
    expect(model_class(model).all).to_not be_empty
    expect(model_class(model).find(obj.id)).to be_a_kind_of model_class(model)
  end

  it "can delete valid #{model.to_s.capitalize}" do
    obj = model_class(model).first
    expect(model_class(model).find(obj.id)).to be_a_kind_of model_class(model)
    model_class(model).destroy(obj.id)
    expect { model_class(model).find(obj.id) }.to raise_exception ActiveRecord::RecordNotFound
  end
end

RSpec.shared_examples 'Uniqueness Validation' do |model, attrs = [], parent = nil|
  let(:ancestr) do
    # !!(!parent) || { parent => FactoryBot.create(parent) }
    create_parent parent
  end

  attrs.each do |attr|
    it "cannot create #{model.to_s.capitalize} with invalid #{attr}" do
      obj = build_db_obj model, ancestr
      obj.send("#{attr}=", nil)
      expect(obj).to_not be_valid
      expect(obj.save).to eq false
      # byebug
      error_checker(obj: obj, key: attr, msg: "can't be blank")
    end

    it "cannot create #{model.to_s.capitalize} with non unique #{attr}" do
      object = build_db_obj model, ancestr
      expect(object).to be_valid
      expect(object.save).to eq true
      expect(object).to be_persisted

      # build Another object with same attr
      bad_obj = build_db_obj model, ancestr
      bad_obj.send("#{attr}=", object.send(attr))
      expect(bad_obj).to_not be_valid
      expect(bad_obj.save).to eq false
      expect(bad_obj).to_not be_persisted

      # expect(bad_obj).to respond_to :errors
      # expect(bad_obj.errors).to respond_to :messages
      # expect(bad_obj.errors.messages).to include /#{attr}/
      # expect(bad_obj.errors.messages).to have_key attr
      # expect(bad_obj.errors.messages[attr]).to include /has already been taken/

      error_checker(obj: bad_obj, key: attr, msg: 'has already been taken')
    end
  end
end
