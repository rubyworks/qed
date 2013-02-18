module QED

  #
  def self.cli(*argv)
    Session.cli(*argv)
  end

  class Session

    #
    # Session settings are passed to `Session.new`.
    #
    #def self.settings
    #  @settings ||= Settings.new
    #end

    #
    # Command line interface for running demos.
    #
    # When running `qed` on the command line tool, QED can use
    # either a automatic configuration file, via the RC library,
    # or setup configuration via an explicitly required file.
    #
    # Using a master configuraiton file, add a `config :qed` entry.
    # For example:
    #
    #     config :qed, :profile=>:simplecov do
    #       require 'simplecov'
    #       SimpleCov.start do
    #         coverage_dir 'log/coverage'
    #       end
    #     end
    #
    # To not use RC, just create a requirable file such as `config/qed-coverage.rb`
    #
    #     QED.configure do |qed|
    #       require 'simplecov'
    #       SimpleCov.start do
    #         coverage_dir 'log/coverage'
    #       end
    #     end
    #
    # Then when running qed use:
    #
    #     $ qed -r ./config/qed-coverage.rb
    #
    def self.cli(*argv)
      require 'optparse'
      require 'shellwords'

      # we are loading this here instead of above so simplecov coverage works better
      # (actually, this is really not a problem anymore, but we'll leave it for now)
      require 'qed/session'

      Utils.load_config

      options = cli_parse(argv)

      settings = Settings.new(options)
      session  = Session.new(settings)
      success  = session.run

      exit -1 unless success
    end

    # 
    # Build an instance of OptionParser.
    #
    def self.cli_parse(argv)
      options = {}

      parser = OptionParser.new do |opt|
        opt.banner = "Usage: qed [options] <files...>"

        opt.separator("Report Formats (pick one):")

        #opt.on('--dotprogress', '-d', "use dot-progress reporter [default]") do
        #  options[:format] = :dotprogress
        #end
        opt.on('--verbatim', '-v', "shortcut for verbatim reporter") do
          options[:format] = :verbatim
        end
        opt.on('--tapy', '-y', "shortcut for TAP-Y reporter") do
          options[:format] = :tapy
        end
        #opt.on('--bullet', '-b', "use bullet-point reporter") do
        #  options[:format] = :bullet
        #end
        #opt.on('--html', '-h', "use underlying HTML reporter") do
        #  options[:format] = :html
        #end
        #opt.on('--script', "psuedo-reporter") do
        #  options[:format] = :script  # psuedo-reporter
        #end
        opt.on('--format', '-f FORMAT', "use custom reporter") do |format|
          options[:format] = format.to_sym
        end

        opt.separator("Control Options:")

        opt.on('-p', '--profile NAME', "load runtime profile") do |name|
          options[:profile] = name
        end
        opt.on('--comment', '-c', "run comment code") do
          options[:mode] = :comment
        end
        opt.on('--loadpath', "-I PATH", "add paths to $LOAD_PATH") do |paths|
          options[:loadpath] = paths.split(/[:;]/).map{|d| File.expand_path(d)}
        end
        opt.on('--require', "-r LIB", "require feature (immediately)") do |paths|
          requires = paths.split(/[:;]/)
          requires.each do |file|
            require file
          end
        end
        opt.on('--rooted', '-R', "run from project root instead of temporary directory") do
          options[:rooted] = true
        end
        opt.on('--trace', '-t [COUNT]', "number of backtraces for exceptions (0 for all)") do |cnt|
          #options[:trace] = true
          ENV['trace'] = cnt
        end
        opt.on('--warn', "run with warnings turned on") do
          $VERBOSE = true # wish this were called $WARN!
        end
        opt.on('--debug', "exit immediately upon raised exception") do
          $DEBUG = true
        end

        opt.separator("Optional Commands:")

        opt.on_tail('--version', "display version") do
          puts "QED #{QED::VERSION}"
          exit
        end
        opt.on_tail('--copyright', "display copyrights") do
          puts "Copyright (c) 2008 Thomas Sawyer, Apache 2.0 License"
          exit
        end
        opt.on_tail('--help', '-h', "display this help message") do
          puts opt

          unless settings.profiles.empty?
            puts "Available Profiles:"
            #require 'confection'
            QED.profiles.each do |name|
              next if name.strip == ''
              puts "    -p #{name}"
            end
          end

          exit -1
        end
      end

      parser.parse!(argv)

      options[:files] = argv unless argv.empty?

      return options
    end

  end

end
