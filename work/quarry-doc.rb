service :quarry_doc do
  pipe :main

  def document
    shell 'quarry-doc -q --file doc/spec/index.html'
    puts "doc/spec/index.html updated."
  end
end

