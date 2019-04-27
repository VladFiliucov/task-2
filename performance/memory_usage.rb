require_relative '../task-2.rb'

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

puts "60k lines text file"
puts "rss before: #{print_memory_usage}"
work("sample_data/60000_lines.txt")
puts "rss after: #{print_memory_usage} \n"

# puts "Large 130MB text file"
# puts "rss before: #{print_memory_usage}"
# work("data_large.txt")
# puts "rss after: #{print_memory_usage}"
