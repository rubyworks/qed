require 'qed/configure'
require 'rc/api'

RC.setup(:qed) do |config|
  #config.profile_switch('-p', '--profile')
  #QED.configure(&confg)
  config.each do |c|
    QED.configure(c.profile, &c)
  end
end

