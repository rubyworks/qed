# This helper is used to demonstrate the use of advice --before, after
# and when clauses.

count   = 0
pudding = []

#Before(:import) do
#  pudding << "load #{File.basename(__FILE__)}"
#end

After(:import) do
  pudding << "loaded #{File.basename(__FILE__)}"
end

#Before do
#  pudding << :before_step
#end

#After do
#  pudding << :after_step
#end

When /.*?/ do
  count += 1
end

When /proof is in the pudding/ do
  pudding << 'proof'
end

#When /proof is in the pussing/ do
#  pudding << :proof
#end

#
def prepare_example
  "Hello, World!"
end

