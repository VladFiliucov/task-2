# frozen_string_literal: true

require 'json'
require 'date'
require 'pry'
# require 'ruby-progressbar'

DELIMITER = ','.freeze
USER_PREFIX = 'user,'.freeze
SESSION_PREFIX = 'session,'.freeze
DATE_PATTERN = '%Y-%m-%d'.freeze

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end

  def sorted_session_dates
    sessions.map! do |s|
      Date.civil(s[:date][0,4].to_i, s[:date][5,2].to_i, s[:date][8,2].to_i)
    end.sort! {|a,b| b <=> a}
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    id: fields[1],
    # here
    name: "#{fields[2]} #{fields[3]}",
    age: fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase!,
    time: fields[4],
    date: fields[5],
  }
end

def work(filename = 'data.txt')
  # progressbar_count = %x( wc -l #{filename} ).to_i

  # progressbar = ProgressBar.create(
  #   title: 'Reading users and sessions: ',
  #   total: progressbar_count,
  #   format: '%t %a, %J, %E %B' # elapsed time, percent complete, estimate, bar
  #   # output: File.open(File::NULL, 'w') # IN TEST ENV
  # )

  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
  }
  users = []
  sessions = []

  file = File.open(filename, 'r')

  # File.foreach(filename) do |line|
  while !file.eof?
   line = file.readline
    # progressbar.increment
    if line.start_with?(SESSION_PREFIX)
      sessions << parse_session(line)
      next if report[:totalSessions] += 1
    end

    if line.start_with?(USER_PREFIX)
      users << parse_user(line)
      report[:totalUsers] += 1
    end
  end

  all_browsers = []
  users_objects = []
  sessions_by_user = {}

  # sessions_parsing_progressbar = ProgressBar.create(
  #   title: 'Processing Sessions: ',
  #   total: sessions.size,
  #   format: '%t %a, %J, %E %B' # elapsed time, percent complete, estimate, bar
  #   # output: File.open(File::NULL, 'w') # IN TEST ENV
  # )

  while sessions[0]
    sess = sessions.shift
    # sessions_parsing_progressbar.increment
    next unless sess
    sessions_by_user[sess[:user_id]] = sessions_by_user[sess[:user_id]] ? (sessions_by_user[sess[:user_id]] << sess) : [sess]
    all_browsers << sess[:browser]
  end

  report[:allBrowsers] = report_all_browsers(all_browsers)
  report[:uniqueBrowsersCount] = all_browsers.size

  users.each do |user|
    attributes = user
    users_objects << User.new(attributes: attributes, sessions: sessions_by_user[user[:id]] || [])
  end

  report['usersStats'] = {}

  # report_preparing_progressbar = ProgressBar.create(
  #   title: 'Preparing report data: ',
  #   total: report[:totalUsers].to_i,
  #   format: '%t %a, %J, %E %B' # elapsed time, percent complete, estimate, bar
  #   # output: File.open(File::NULL, 'w') # IN TEST ENV
  # )

  counter = 0
  while report[:totalUsers] > counter
    # report_preparing_progressbar.increment
    u = users_objects.shift
    user_key = u.attributes[:name]

    user_sessions_time = u.sessions.map { |s| s[:time].to_i }
    user_browsers = u.sessions.map { |s| s[:browser] }

    report['usersStats'][user_key] = {
      'sessionsCount' => u.sessions.size,
      'totalTime' => user_sessions_time.sum.to_s << ' min.',
      'longestSession' => user_sessions_time.max.to_s << ' min.',
      'browsers' => user_browsers.sort.join(', '),
      'usedIE' => !user_browsers.find { |b| b =~ /INTERNET EXPLORER/ }.nil?,
      'alwaysUsedChrome' => !user_browsers.find { |b| b !~ /CHROME/ },
      'dates' => u.sorted_session_dates
      # line up
    }
    counter += 1
  end

  # Собираем количество сессий по пользователям

  File.write("result.json", report.to_json << "\n")
end

private

def report_all_browsers(browsers)
  browsers.uniq!
    .sort!
    .join(DELIMITER)
end
#
# system("sed -n '2p' sample_data/1000_lines.txt")

# Benchmark.bmbm(2) do |x|
#   filenames.each do |fn|
#     x.report(fn) do
#       2.times do
#         work("sample_data/#{fn}.txt")
#       end
#     end
#   end
# end
#
# require 'memory_profiler'

# MemoryProfiler.start

# work("sample_data/20000_lines.txt")

# report = MemoryProfiler.stop
# report.pretty_print(scale_bytes: true)
# work("data_large.txt")
