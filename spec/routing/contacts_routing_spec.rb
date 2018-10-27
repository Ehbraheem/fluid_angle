require "rails_helper"

RSpec.describe ContactsController, type: :routing do
  it_should_behave_like 'routing', :contact

  context 'Starred Contact' do
    it 'routes to #stars' do
      expect(get: contacts_stars_path).to route_to('contacts#stars', format: :json)
    end

    it 'routes to #stars for a single contact' do
      expect(get: contacts_star_path(1)).to route_to('contacts#star', id: '1', format: :json)
    end

    it 'edit star for a single contact' do
      expect(put: contacts_star_path(1)).to route_to('contacts#edit_star', id: '1', format: :json)
    end
  end
end
