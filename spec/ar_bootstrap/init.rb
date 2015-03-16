PROJECT_ROOT = File.expand_path File.join(File.dirname(__FILE__), '../..')

require 'active_record'

# rails is needed for ActiveRecord::Tasks::DatabaseTasks
require 'rails'

# Rails.root is needed for ActiveRecord::Tasks::DatabaseTasks
def Rails.root
  PROJECT_ROOT
end

# load database.yml
ActiveRecord::Base.configurations = YAML.load_file(File.join(PROJECT_ROOT, 'spec/ar_bootstrap/database.yml'))
# drop all DBs
ActiveRecord::Tasks::DatabaseTasks.drop_all

# iterate through each connection in database.yml
ActiveRecord::Tasks::DatabaseTasks.send(:each_local_configuration) do |config|
  # create DB
  ActiveRecord::Tasks::DatabaseTasks.send(:create, config)
  # connect to it
  ActiveRecord::Base.establish_connection config
  # load schema into it
  load File.join(PROJECT_ROOT, 'spec/ar_bootstrap/schema.rb')
end

class Blog < ActiveRecord::Base
  has_many :page_views
end

class PageView < ActiveRecord::Base
  belongs_to :blog
end
