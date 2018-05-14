require 'rubygems'
require 'bundler/setup'

require 'active_record'

namespace :db do
  db_config = YAML.safe_load(File.open('config/database.yml'))
  # db_config_admin = db_config.merge('database' => 'postgres', 'schema_search_path' => 'public')

  # db_config_admin = SQLite3::Database.open 'employee.db'
  # puts db.get_first_value 'SELECT SQLITE_VERSION()'

  DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
  MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'

  def establish_connection
    db_config = YAML.safe_load(File.open('config/database.yml'))

    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      # dbfile: ':memory:'
      database: db_config['database']
    )
  end

  # desc 'Drops the database for the current DATABASE_ENV'
  # task drop: :configure_connection do
  #   ActiveRecord::Base.connection.drop_database @config['database']
  # end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task :migrate do
    establish_connection
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate MIGRATIONS_DIR, ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback do
    establish_connection
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
  end

  desc 'Retrieves the current schema version number'
  task :version do
    establish_connection
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  # desc 'Check the database'
  # task :check do
  #   # ActiveRecord::Base.establish_connection(db_config_admin)
  #   establish_connection
  #   puts "Database: #{ActiveRecord::Base.connection.execute('SELECT SQLITE_VERSION()')}"
  # end
  #
  # desc 'Create the database'
  # task :create do
  #   # ActiveRecord::Base.establish_connection(db_config_admin)
  #   establish_connection
  #   ActiveRecord::Base.connection.create_database(db_config['database'])
  #   puts 'Database created.'
  # end
  #
  # desc 'Migrate the database'
  # task :migrate do
  #   # ActiveRecord::Base.establish_connection(db_config)
  #   establish_connection
  #   ActiveRecord::Migrator.migrate('db/migrate/')
  #   Rake::Task['db:schema'].invoke
  #   puts 'Database migrated.'
  # end
  #
  # desc 'Drop the database'
  # task :drop do
  #   establish_connection
  #   # ActiveRecord::Base.establish_connection(db_config_admin)
  #   ActiveRecord::Base.connection.drop_database(db_config['database'])
  #   puts 'Database deleted.'
  # end
  #
  # desc 'Reset the database'
  # task reset: %i[drop create migrate]
  #
  # desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  # task :schema do
  #   # ActiveRecord::Base.establish_connection(db_config)
  #   establish_connection
  #   require 'active_record/schema_dumper'
  #   filename = 'db/schema.rb'
  #   File.open(filename, 'w:utf-8') do |file|
  #     ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
  #   end
  # end
end

namespace :g do
  desc 'Generate migration'
  task :migration do
    name = ARGV[1] || raise('Specify name: rake g:migration your_migration')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split('_').map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<-EOF
class #{migration_class} < ActiveRecord::Migration

  def self.up
  end

  def self.down
  end

end
      EOF
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
