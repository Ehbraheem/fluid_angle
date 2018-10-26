require "rails_helper"

RSpec.describe ContactsController, type: :routing do
  it_should_behave_like 'routing', :contact
end
