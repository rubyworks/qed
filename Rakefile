#!/usr/bin/env ruby

desc "run tests"
task :test do
  pass1 = system "ruby -Ilib -- bin/qed spec/*.rdoc"
  pass2 = system "ruby -Ilib -- bin/qed test/integration/*.rdoc"
  exit -1 unless pass1 && pass2
end

desc "generate qedocs"
task :qedoc do
  sh 'qedoc -o site/docs/qedoc/ -t "QED Demonstrandum" qed/*.rdoc'
end

