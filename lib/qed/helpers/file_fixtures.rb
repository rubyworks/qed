module QED

  # This extension provides a simple means for creatind file-system fixtures.
  # Include this in your applique, to have a
  module FileFixtures

    #
    def self.included(base)
      require 'erb'
    end

    #
    def copy_fixture(name, tmpdir=nil)
      tmpdir ||= 'tmp' # self.tmpdir
      FileUtils.mkdir(tmpdir) unless File.directory?(tmpdir)
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

  end

end

