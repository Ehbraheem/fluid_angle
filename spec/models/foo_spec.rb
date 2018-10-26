require 'rails_helper'

RSpec.describe Foo, type: :model do
  include_context 'db_cleanup_each'

  it_should_behave_like 'Existing object', %i(foo)

  it_should_behave_like 'valid with valid attributes', %i(foo)

  it_should_behave_like 'invalid with invalid attributes', %i(foo)

  it_should_behave_like 'CRUD', %i(foo)
end
