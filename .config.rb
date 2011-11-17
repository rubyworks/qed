qed do

  profile :sample do
    puts ("*" * 78)
    puts

    at_exit do
      puts
      puts ("*" * 78)
    end
  end

  profile :cov do
    require 'simplecov'
    SimpleCov.start do
      coverage_dir 'log/coverage'
      #add_group "Label", "lib/qed/directory"
    end
  end

  profile :rcov do
    require 'rcov';
    #require 'rcov/report'

    $qed_rcov_analyzer = Rcov::CodeCoverageAnalyzer.new

    at_exit do
      $qed_rcov_analyzer.remove_hook;
      $qed_rcov_analyzer.dump_coverage_info([Rcov::TextReport.new]);
      Rcov::HTMLCoverage.new(
        :color => true,
        :fsr => 30,
        :destdir => "log/rcov",
        :callsites => false,
        :cross_references => false,
        :charset => nil 
      ).execute
    end
  end

end
