require 'fileutils'

raise "not ready yet"

module Quarry

  # Extractor is a tool for extracting code from embedded
  # comment blocks.
  #
  # TODO:
  #   - Should extract_block handle more than the first matching block?
  #   - How can we handle embedded code in standard comments? Eg. #
  #
  module Extract

    extend self

    # Extract unit tests. This task scans every package script
    # looking for sections of the form:
    #
    #     =begin test
    #       ...
    #     =end
    #
    # With appropriate headers, it copies these sections to files
    # in your project's test/ dir, which then can be run using the
    # Ratchet test task. The exact directory layout of the files to
    # be tested is reflected in the test directory. You can then
    # use project.rb's test task to run the tests.
    #
    #     files      Files to extract ['lib/**/*.rb']
    #     output     Test directory   ['test/']
    #

    def test_extract(files=nil)
      output = 'test/embedded'     # Don't think output should be setable.

      files  = files || 'lib/**/*.rb'
      files = 'lib/**/*.rb' if TrueClass == files
      files = [files].flatten.compact

      filelist = files.collect{ |f| Dir.glob(f) }
      filelist.flatten!
      if filelist.empty?
        puts "No scripts found from which to extract tests."
        return
      end

      FileUtils.mkdir_p(output) unless File.directory?(output)

      #vrunner = VerbosityRunner.new("Extracting", verbosity?)
      #vrunner.setup(filelist.size)

      filelist.each do |file|
        #vrunner.prepare(file)

        testing = extract_test_from_file( file )
        if testing.strip.empty?
          status = "[NONE]"
        else
          complete_test = create_test(testing, file)
          libpath = File.dirname(file)
          testfile = "test_" + File.basename(file)
          fp = File.join(output, libpath, testfile)
          unless File.directory?( File.dirname(fp))
            FileUtils.mkdir_p(File.dirname(fp))
          end
          File.open(fp, "w"){ |fw| fw << complete_test }
          status = "[TEST]"
        end

        #vrunner.complete(file, status)
      end

      #vrunner.finish(
      #  :normal => "#{filelist.size} files had tests extracted.",
      #  :check => false
      #)
    end

    private

    # Extract test from a file's testing comments.

    def extract_test_from_file(file)
      return nil if ! File.file?(file)
      tests = ""; inside = false
      fstr = File.read(file)
      fstr.split(/\n/).each do |l|
        if l =~ /^=begin[ ]*test/i
          tests << "\n"
          inside = true
          next
        elsif inside and l =~ /^=[ ]*end/
          inside = false
          next
        end
        if inside
          tests << l << "\n"
        end
      end
      tests
    end

    # Generate the test.

    def create_test(testing, file)
      fp = file.split(/[\/]/)
      if fp[0] == 'lib'
        reqf = "require '#{fp[1..-1].join('/')}'"
      else
        reqf = ''
      end
      teststr = []
      teststr << "#  _____         _"
      teststr << "# |_   _|__  ___| |_"
      teststr << "#   | |/ _ \\/ __| __|"
      teststr << "#   | |  __/\\__ \\ |_"
      teststr << "#   |_|\\___||___/\\__|"
      teststr << "#"
      teststr << "# for #{file}"
      teststr << "#"
      teststr << "# Extracted #{Time.now}"
      teststr << "# Project.rb Test Extraction"
      teststr << "#"
      teststr << ""
      teststr << "#{reqf}"
      teststr << ""
      teststr << testing
      teststr << ""
      teststr.join("\n")
    end

  end #module Extract

end #module Quarry

