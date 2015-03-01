require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

load File.join(File.dirname(__FILE__), './schema.rb')

class Blog < ActiveRecord::Base
end

class PageView < ActiveRecord::Base
  belongs_to :blog
end
