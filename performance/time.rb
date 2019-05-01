require_relative '../task-2.rb'
require "benchmark"

Benchmark.bmbm(2) do |x|
  x.report('Big file') do
    work("data_large.txt")
  end
end

# Benchmark.bmbm(2) do |x|
#   x.report('Big file') do
#     work("sample_data/60000_lines.txt")
#   end
# end
