ignore 'work'

book :index do
  rule 'var/*' do
    sh 'index -u var'
  end
end

book :test do
  # I don't know why this won't work!!!
  rule '{demo,lib}/**/*' do
    #sh 'qed'
    require 'simplecov'
    SimpleCov.command_name 'demo'
    SimpleCov.start do
      add_filter '/demo/'
      coverage_dir 'log/coverage'
      #add_group "Label", "lib/qed/directory"
    end
    require 'qed/cli'
    QED::Session.cli('-Ilib', 'demo/')
  end
end

