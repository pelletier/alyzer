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
  couch_host: "http://localhost:5984",
  couch_db: "alyzer",
  start_time: 1.year.ago,
  density: 72 # messages a day

}

OptionParser.new do |opts|
  opts.banner = "Usage: generate_fake.rb [options]"

  opts.on("-h", "--host", "CouchDB host") { |v| options[:couch_host] = v }
  opts.on("-d", "--database", "CouchDB database") { |v| options[:couch_db] = v }
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


db = CouchRest.new(options[:couch_host]).database!(options[:couch_db])


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
