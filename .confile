#
# Setup QED.
#
qed do

  # Just to demonstrate profiles.
  profile :sample do
    puts ("*" * 78)
    puts

    at_exit do
      puts
      puts ("*" * 78)
    end
  end

  # Create coverage report.
  profile :cov do
    require 'simplecov'
    SimpleCov.start do
      coverage_dir 'log/coverage'
      #add_group "Label", "lib/qed/directory"
    end
  end

end
