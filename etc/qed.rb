# QED demo configuration

# This is just an example, we can't actually use it
# for QED itself b/c Simplecov wouldn't be able to
# cover it b/c QED would already be loaded.
QED.configure 'cov' do
  require 'simplecov'
  SimpleCov.command_name 'demo'
  SimpleCov.start do
    add_filter '/demo/'
    coverage_dir 'log/coverage'
    #add_group "Label", "lib/qed/directory"
  end
end

# Just a silly example to try out.
QED.configure 'sample' do
  puts ("*" * 78)
  puts

  at_exit do
    puts
    puts ("*" * 78)
  end
end

