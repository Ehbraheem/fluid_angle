module ApiHelper
  # include ::ModelsHelper
  
  def parsed_body
    JSON.parse response.body
  end

  %i(post get put patch head delete).each do |verb|
    define_method "j#{verb}" do |path, params = {}, headers = {}|
      if %i(post put patch).include?(verb)
        headers = headers.merge('Content-Type' => 'application/json') unless params.empty?
        params = params.to_json
      end
      # byebug
      # self.send(verb,
      send(verb,
        path,
        params: params,
        headers: headers.merge(access_tokens))
    end
  end

  def signup(reg, status = :ok)
    jpost user_registration_path, reg
    expect(response).to have_http_status status
    payload = parsed_body
    reg.merge(id: payload['data']['id'], uid: payload['data']['uid']) if response.ok?
  end

  def login(credentials, status = :ok) 
    jpost user_session_path, credentials.slice(:username, :password)
    # pp parsed_body
    # byebug
    expect(response).to have_http_status status
    response.ok? ? parsed_body['data'] : parsed_body
  end

  def logout(status = :ok)
    jdelete destroy_user_session_path
    @last_tokens = {}
    expect(response).to have_http_status status if status
  end

  def access_tokens?
    !response.headers['access-token'].nil? if response
  end

  def access_tokens
    if access_tokens?
      @last_tokens = %w(uid client token-type access-token).inject({}) { |mem, var| mem[var] = response.headers[var]; mem }
    end
    @last_tokens || {}
  end

  def user_attr
    FactoryBot.attributes_for :user
  end

  # Vague solution to avoid leaking User instance and to simulate real life scenario of 1 Authenticated User => Many Contacts
  def create_parent_mock(parent)
    if parent == :user # Valid JSON payload from server
      account = signup user_attr, :ok
      user = login account, :ok
      { user_id: user['id'] }
    else
      create_parent parent
    end
  end
end

RSpec.shared_examples 'all resource' do |model, parent = nil|
  let(:ancestr) { create_parent_mock parent }
  let!(:resources) { (1..5).map { |e| FactoryBot.create model, ancestr } }
  let(:payload) { parsed_body }

  it 'check request/response' do
    jget send("#{model}s_path"), {}, 'Accept' => 'application/json' 
    expect(request.method).to eq 'GET'
    expect(response).to have_http_status :ok
    expect(response.content_type).to eq 'application/json'
  end

  it 'returns all resource' do
    jget send("#{model}s_path"), {}, 'Accept' => 'application/json' 

    expect(response).to have_http_status :ok
    expect(payload.count).to eq resources.count
    response_check if respond_to?(:response_check)
  end
end

RSpec.shared_examples 'specific resource' do |model, parent = nil|
  let(:ancestr) { create_parent_mock parent }
  let(:resource) { FactoryBot.create model, ancestr }
  let(:bad_id) { 4_556_645 }
  let(:payload) { parsed_body }

  it "returns #{model.to_s.classify} when given correct ID" do
    jget send("#{model}_path", resource.id)
    expect(response).to have_http_status :ok
    expect(response.content_type).to eq 'application/json'

    response_check if respond_to?(:response_check)
  end

  it 'returns not found using incorrect ID' do
    jget send("#{model}_path", bad_id)
    expect(response).to have_http_status :not_found
    expect(response.content_type).to eq 'application/json'

    error_check if respond_to?(:error_check)
  end
  
end

RSpec.shared_examples 'create a new resource' do |model, parent = nil|
  let(:ancestr) { create_parent_mock parent }
  let(:resource_attr) { FactoryBot.attributes_for model, ancestr }

  it "can create #{model.to_s.classify}" do
    jpost send("#{model}s_path"), model => resource_attr 
    expect(response).to have_http_status :created
    expect(response.content_type).to eq 'application/json'

    check_data if respond_to?(:check_data)
  end
  
end

RSpec.shared_examples 'existing resource' do |model, parent = nil|
  let(:ancestr) { create_parent_mock parent }
  let(:resource) { FactoryBot.create model, ancestr }
  let(:new_state) { FactoryBot.attributes_for model }

  it 'can be updated from API endpoint' do
    pre_check if respond_to?(:pre_check)
    jput send("#{model}_path", resource.id), model => new_state 
    expect(response).to have_http_status :ok
    post_check if respond_to?(:post_check)
  end

  it 'can be deleted from API endpoint' do
    jhead send("#{model}_path", resource.id)
    expect(response).to have_http_status :ok

    jdelete send("#{model}_path", resource.id)
    expect(response).to have_http_status :no_content

    jhead send("#{model}_path", resource.id)
    expect(response).to have_http_status :not_found
  end
end
