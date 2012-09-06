#!/usr/bin/env ruby
require 'active_support/all'
require 'couchrest'
require 'optparse'
#require 'random'
require 'ruby-progressbar'


words_list = [
  "struck",
  "strung",
  "absent",
  "banging",
  "basket",
  "bathtub",
  "bedbug",
  "blasted",
  "blended",
  "bobsled",
  "branch",
  "camping",
  "catnip",
  "chipmunk",
  "contest",
  "crashing",
  "dentist",
  "disrupt",
  "disrupted",
  "drinking",
  "dusted",
  "expanded",
  "finishing",
  "goblin",
  "himself",
  "hotrod",
  "hunted",
  "insisted",
  "insisting",
  "insulted",
  "invent"
]


options = {
  start_time: 1.year.ago,
  density: 72 # messages a day

}

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

OptionParser.new do |opts|
  opts.banner = "Usage: generate_fake.rb [options]"

  opts.on("-s", "--start", "Start date. Ruby expression that should evaluate to a date") do |v|
    options[:start_time] = eval(v)
  end
  opts.on("-D", "--density", Integer, "Number of messages a day") { |v| options[:density] = v }
  opts.on("-w", "--words-number", Integer, "Number of words available to the generator") do |v|
    if v < words_list.length
      words_list = words_list[0...v]
    end
  end
end.parse!


random = Random.new()

def create_doc(day, random, words_list)
  return {
    date: day.beginning_of_day() + random.rand(86400),
    domain: words_list.sample(),
    uuid: 10000+random.rand(10000),
    name: words_list.sample(),
    timing: 50+random.rand(300), # in ms
    code: random.rand() > 0.7 ? 500 : 200
  }
end


db = CouchRest.new(db_config[:url]).database!(db_config[:db])


stop_day = Time.now
current_day = options[:start_time]
progress = ProgressBar.create(format: '%a %E |%b>>%i| %p%% %t',
                              total: (stop_day - options[:start_time]).to_i / 86400)

while current_day < stop_day
  variation = (options[:density] * 0.1).round
  delta = random.rand(variation)
  (options[:density]-variation+delta).times do
    db.save_doc(create_doc(current_day, random, words_list))
  end
  current_day += 1.day
  progress.increment
end
