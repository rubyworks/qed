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

