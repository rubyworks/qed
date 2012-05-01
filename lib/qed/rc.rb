begin
  require 'rc'
  RC.profile_switch('qed', '-p', '--profile')
  RC.configure 'qed' do |config|
    QED.configure(config.profile, &config)
  end
rescue LoadError
end

require 'qed/configure'
require 'qed'

