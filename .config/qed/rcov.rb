require 'ae/should'

QED::Runner.configure do

  start do
    require 'rcov';
    #require 'rcov/report';
    $qed_rcov_analyzer = Rcov::CodeCoverageAnalyzer.new
  end

  finish do
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

