require 'rails_helper'

RSpec.describe FoosController, type: :routing do
  it_should_behave_like 'routing', :foo
end
