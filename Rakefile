require 'bcrypt'
require 'couchrest'
require 'highline/import'
require 'yaml'


def head(string)
  say("<%= color('#{"="*string.length}', :red, BOLD) %>")
  say("<%= color('#{string}', :red, BOLD) %>")
  say("<%= color('#{"="*string.length}', :red, BOLD) %>")
  puts "\n"*2
end

def part(string)
  say("\n<%= color('** #{string}', :yellow) %>")
end

def success(string)
  say("\n<%= color('** #{string}', :green) %>")
end

def ask_for(name, &block)
  ask("<%= color('#{name}: ', :blue) %>", &block)
end


def get_db
  begin
    db_config = YAML.load_file('config/db.yml')
  rescue Errno::ENOENT
    db_config = {
      url: ENV['ALYZER_COUCH_URL'],
      db: ENV['ALYZER_COUCH_DB']
    }
  end
  
  return CouchRest.new(db_config[:url]).database!(db_config[:db])
end


namespace :user do

  desc "Create a new user"
  task :create do
    username = ask_for("Username") do |q|
      q.validate = /\w+/
      q.default = "admin"
    end

    password = ask_for("Enter a password") do |q|
      q.validate = /.+/
      q.echo = false
      q.verify_match = true
      q.gather = {"Enter a password" => '',
                  "Please type it again for verification" => ''}
    end

    crypted_password = BCrypt::Password.create(password)

    doc = {
      '_id' => "alizer-config",
      users: [
        {username: username, password: crypted_password}
      ]
    }

    db = get_db()

    begin
      db.save_doc(doc)
    rescue RestClient::Conflict
      db.update_doc('alizer-config') do |couch_doc|
        couch_doc['users'] = doc[:users]
      end
    end
  end

end

namespace :config do

  desc "Create the DB configuration"
  task :db do
    while true
      couch_url = ask_for("URL") do |q|
        q.validate = /\w+/
        q.default = "http://127.0.0.1:5984"
      end
      couch_database = ask_for("Database") do |q|
        q.validate = /[a-z0-9_$()+\/-]+/
        q.default = "alyzer"
      end

      begin
        db = CouchRest.new(couch_url).database!(couch_database)
        break
      rescue Exception => e
        puts "Unable to create the database:"
        puts e
        puts "Please re-enter the settings:"
      end
    end

    hash = {
      url: couch_url,
      db: couch_database
    }
    File.open("config/db.yml", "w") do |f|
      f.write(hash.to_yaml)
    end
  end

end

namespace :install do

  desc "Create the configuration and the first user"
  task :run do
    head "Alyzer setup script"

    part "CouchDB settings"
    Rake::Task['config:db'].invoke

    part "First user creation"
    Rake::Task['user:create'].invoke

    success "The configuration is done! Just start the server and have fun."
  end

end
