
# ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :blogs, force: true do |t|
    t.integer :arbitrary_number
    t.timestamps null: false
  end

  create_table :page_views, force: true do |t|
    t.references :blog
    t.datetime :date
    t.integer :count
  end

end
