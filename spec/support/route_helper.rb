RSpec.shared_examples 'routing' do |model|
  it 'routes to #index' do
    expect(get: send("#{model}s_path")).to route_to("#{model}s\#index", format: :json)
  end

  it 'routes to #show' do
    expect(get: send("#{model}_path", 1)).to route_to("#{model}s\#show", id: '1', format: :json)
  end

  it 'routes to #create' do
    expect(post: send("#{model}s_path")).to route_to("#{model}s\#create", format: :json)
  end

  it 'routes to #update via PUT' do
    expect(put: send("#{model}_path", 1)).to route_to("#{model}s\#update", id: '1', format: :json)
  end

  it 'routes to #update via PATCH' do
    expect(patch: send("#{model}_path", 1)).to route_to("#{model}s\#update", id: '1', format: :json)
  end

  it 'routes to #destroy' do
    expect(delete: send("#{model}_path", 1)).to route_to("#{model}s\#destroy", id: '1', format: :json)
  end
end
