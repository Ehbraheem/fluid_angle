require 'database_cleaner'

shared_context 'db_cleanup' do |strategy = :truncation|
  before(:all) do
    DatabaseCleaner[:active_record].strategy = strategy
    DatabaseCleaner.clean_with(:truncation)
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end
end

shared_context 'db_scope' do
  before(:each) do
    DatabaseCleaner.start
  end

  after(:each) do
    DatabaseCleaner.clean
  end
end

shared_context 'db_cleanup_each_test' do |strategy = :truncation|
  before(:all) do
    DatabaseCleaner[:active_record].strategy = strategy
    DatabaseCleaner.clean_with :truncation
  end

  after(:all) do
    DatabaseCleaner.clean_with :truncation
  end

  before(:each) do
    DatabaseCleaner.start
  end

  after(:each) do
    DatabaseCleaner.clean
  end
end

shared_context 'db_cleanup_greedy' do
  before(:all) do
    DatabaseCleaner[:active_record].strategy = :truncation
    DatabaseCleaner.clean_with :truncation
  end

  after(:all) do
    DatabaseCleaner.clean_with :truncation
  end
end

shared_context 'db_cleanup_each' do |strategy = :truncation|
  include_context 'db_cleanup', strategy
  include_context 'db_scope'
  include_context 'db_cleanup_each_test', strategy
end
