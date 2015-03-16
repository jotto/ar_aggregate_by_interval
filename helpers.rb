ActiveRecord::Base.establish_connection adapter: 'mysql2', database: 'stocks'
class Quote < ActiveRecord::Base
end



ActiveRecord::Base.establish_connection adapter: 'postgresql', database: 'traianbasecu'
class Click < ActiveRecord::Base
end
r=Click.count_daily(:created_at, 3.month.ago).values_and_dates.collect{|z|z[:date]}






r=Click.count_weekly(:created_at, 3.month.ago).instance_variable_get('@wut').to_a.first.attributes


ArAggregateByInterval::Utils.ar_to_hash(Click.count_daily(:created_at, 3.month.ago).instance_variable_get('@wut'), {'datechunk__' => 'totalchunked__'})
ArAggregateByInterval::Utils.ar_to_hash(Click.count_weekly(:created_at, 3.month.ago).instance_variable_get('@wut'), {'datechunk__' => 'totalchunked__'})


Bundler.require
require 'rails'
ActiveRecord::Base.configurations = YAML.load_file('./config/database.yml')

ActiveRecord::Tasks::DatabaseTasks.send(:each_local_configuration) do |config|
  begin
    ActiveRecord::Tasks::DatabaseTasks.send(:drop, config)
  rescue
  end
  begin
    ActiveRecord::Tasks::DatabaseTasks.send(:create, config)
  rescue
  end

  ActiveRecord::Base.establish_connection config
  load './spec/ar_bootstrap/schema.rb'
end
