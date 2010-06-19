When "lets say we have", "document called (((.*?))) with the following contents" do |file, text|
  file = Dir.tmpdir + '/sow/examples/' + file
  FileUtils.mkdir_p(File.dirname(file))
  File.open(file, 'w'){ |f| f << text }
end

When 'when we run these examples' do
  Dir.chdir(Dir.tmpdir + '/sow/examples/')
end

