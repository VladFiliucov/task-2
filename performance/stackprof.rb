require_relative '../task-2.rb'

require 'stackprof'

StackProf.run(mode: :object, out: 'tmp/stackprof.dump', raw: true) do
  work("sample_data/60000_lines.txt")
end

profile_data = StackProf.run(mode: :object) do
  work("sample_data/60000_lines.txt")
end

StackProf::Report.new(profile_data).print_text
StackProf::Report.new(profile_data).print_graphviz

# stackprof tmp/stackprof.dump --method 'Object#work'
# stackprof tmp/stackprof.dump --text --limit 3
