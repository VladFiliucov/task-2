# Flat
# Graph
# Callstack
# Callgrind

require_relative '../task-2.rb'

require 'ruby-prof'

GC.disable

mode = ARGV[0] || "flat"

RubyProf.measure_mode = RubyProf::WALL_TIME

modes = {
  "flat" => {
    klass: RubyProf::FlatPrinter,
    ext: "txt"
  },
  "graph" => {
    klass: RubyProf::GraphHtmlPrinter,
    ext: "html"
  },
  "callstack" => {
    klass: RubyProf::CallStackPrinter,
    ext: "html"
  },
  "callgrind" => {
    klass: RubyProf::CallTreePrinter
  }
}

result = RubyProf.profile do
  work('sample_data/60000_lines.txt')
end

printer = modes[mode][:klass].new(result)

if mode != "callgrind"
  printer.print(File.open("tmp/ruby_prof_#{mode}.#{modes[mode][:ext]}", "w+"))
else
  printer.print(path: "tmp/", profile: "callgrind")
end

GC.enable

# # print a graph profile to text
# printer = RubyProf::GraphPrinter.new(result)
# printer.print(STDOUT, {})
