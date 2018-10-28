module ControllersHelper
  def valid_model_attrs(model, parent = nil)
    FactoryBot.attributes_for model, ancestr(parent)
  end

  def ancestr(parent)
    # TODO: Fix memoization helper
    # @last_parent ||= parent
    # @ancestr ||= create_parent parent
    create_parent parent
  end

  def invalid_model_attr(model, parent = nil)
    !!(!parent) ? 
      FactoryBot.attributes_for(model, :invalid) :
      FactoryBot.attributes_for(model, :invalid, ancestr(parent))
  end

  def login_helper(attr)
    # byebug
    request.headers.merge! User.find(attr[:user_id]).create_new_auth_token
    sign_in User.find(attr[:user_id])
  end
end

RSpec.shared_examples 'GET #index' do |model, parent = nil|
  let(:valid_attributes) { valid_model_attrs(model, parent) }
  let(:valid_session) { parent.nil? ? {} : login_helper(valid_attributes) }

  it 'returns a success response' do
    model_class(model).create! valid_attributes
    get :index, params: {}, session: valid_session
    # byebug
    expect(response).to be_successful
  end
end

RSpec.shared_examples 'GET #show' do |model, parent = nil|
  let(:valid_attributes) { valid_model_attrs(model, parent) }
  let(:valid_session) { parent.nil? ? {} : login_helper(valid_attributes) }

  it 'returns a success response' do
    obj = model_class(model).create! valid_attributes
    get :show, params: { id: obj.to_param }, session: valid_session
    expect(response).to be_successful
  end
end

RSpec.shared_examples 'POST #create' do |model, parent = nil|
  let(:valid_attributes) { valid_model_attrs(model, parent) }
  let(:invalid_attributes) { invalid_model_attr(model, parent) }
  let(:valid_session) { parent.nil? ? {} : login_helper(valid_attributes) }

  context 'with valid params' do
    it "creates a new #{model}" do
      expect {
        post :create, params: { model.to_s => valid_attributes }, session: valid_session
      }.to change(model_class(model), :count).by(1)
    end

    it "renders a JSON response with the new #{model}" do
      post :create, params: { model.to_s => valid_attributes }, session: valid_session
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq('application/json')
      expect(response.location).to eq(send("#{model}_url", (model_class(model).last)))
    end
  end

  context 'with invalid params' do
    it "renders a JSON response with errors for the new #{model}" do
      post :create, params: { model.to_s => invalid_attributes }, session: valid_session
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq('application/json')
    end
  end
end

RSpec.shared_examples 'PUT #update' do |model, attrs, parent = nil|
  let(:valid_attributes) { valid_model_attrs(model, parent) }
  let(:invalid_attributes) { invalid_model_attr(model, parent) }
  let(:valid_session) { parent.nil? ? {} : login_helper(valid_attributes) }

  context 'with valid params' do
    let(:new_attributes) { valid_model_attrs(model, parent) }

    it "updates the requested #{model}" do
      obj = model_class(model).create! valid_attributes
      put :update, params: { 'id' => obj.to_param, model.to_s => new_attributes }, session: valid_session
      obj.reload
      expect(response).to have_http_status :ok
      # byebug
      attrs.each do |attr|
        # byebug
        expect(obj.send(attr)).to eq new_attributes[attr]
      end
    end

    it "renders a JSON response with the #{model}" do
      obj = model_class(model).create! valid_attributes

      put :update, params: { 'id' => obj.to_param, model.to_s => valid_attributes }, session: valid_session
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  context 'with invalid params' do
    it "renders a JSON response with errors for the #{model}" do
      obj = model_class(model).create! valid_attributes

      put :update, params: { 'id' => obj.to_param, model.to_s => invalid_attributes }, session: valid_session
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq('application/json')
    end
  end
end

RSpec.shared_examples 'DELETE #destroy' do |model, parent = nil|
  let(:valid_attributes) { valid_model_attrs(model, parent) } 
  let(:valid_session) { parent.nil? ? {} : login_helper(valid_attributes) }

  it "destroys the requested #{model}" do
    obj = model_class(model).create! valid_attributes
    expect {
      delete :destroy, params: { id: obj.to_param }, session: valid_session
    }.to change(model_class(model), :count).by(-1)
  end
end
