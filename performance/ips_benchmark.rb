require_relative '../task-2.rb'

filenames = ['20000_lines', '60000_lines']

require "benchmark/ips"

Benchmark.ips do |x|
  x.config(:stats => :bootstrap, :confidence => 99)

  filenames.each do |filename|
    x.report(filename) do
      work("sample_data/#{filename}.txt")
    end
  end
  x.compare!
end
