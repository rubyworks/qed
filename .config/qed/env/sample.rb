require 'ae/should'

QED::Runner.configure do

  start do
    puts ("*" * 78)
    puts
  end

  finish do
    puts
    puts ("*" * 78)
  end

end

