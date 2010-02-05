require 'ae/should'

QED.config do

  Before do
    puts ("*" * 78)
    puts
  end

  After do
    puts
    puts ("*" * 78)
  end

end

