#require 'ae/expect'

# try rcov option
# TODO: add a qed command option to check here
#require 'rcov'

#$qed_rcov_analyzer = Rcov::CodeCoverageAnalyzer.new

#QED.Before do
#  $qed_rcov_analyzer.install_hook
#end

#QED.After do
#  $qed_rcov_analyzer.remove_hook
#end

#at_exit do
#  $qed_rcov_analyzer.remove_hook
#  $qed_rcov_analyzer.dump_coverage_info([Rcov::TextReport.new]) 
#  # use Rcov::HTMLCoverage above to generate HTML reports; the formatters admit
#  # a number of options, listed in rcov's RDoc documentation.
#end

