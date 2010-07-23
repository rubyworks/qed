# This extension provides a simple means for 
# create file-system fixtures.

require 'erb'

# Set global temporary directory.
$tmpdir = 'tmp'

#
def copy_fixture(name, tmpdir=$tmpdir)
  FileUtils.mkdir(tmpdir)
  srcdir = File.join(demo_directory, 'fixtures', name)
  paths  = Dir.glob(File.join(srcdir, '**', '*'), File::FNM_DOTMATCH)
  paths.each do |path|
    basename = File.basename(path)
    next if basename == '.'
    next if basename == '..'
    dest = File.join(tmpdir, path.sub(srcdir+'/', ''))
    if File.directory?(path)
      FileUtils.mkdir(dest)
    else
      text = ERB.new(File.read(path)).result
      File.open(dest, 'w'){ |f| f << text }
    end
  end
end

