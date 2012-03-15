module QED

  # Settings ecapsulates setup code for running QED.
  #
  # QED can use Confection-based configuration, if a Confile is present.
  #
  # QED also supports configuration files placed in `task/<profile>.qed`.
  #
  # Configuration may also be placed at project root level in `qed.rb`,
  # or if you're old-school, a `.qed` hidden file can still be used. If you
  # don't like any of these choices, QED supports configuration file mapping
  # via the `.map` file. Just add a `qed: path/to/qed/config/file` entry.
  #
  # In this file special configuration setups can be placed to automatically
  # effect QED execution, in particular optional profiles can be defined.
  #
  #     if ENV['cover']
  #       require 'simplecov'
  #       SimpleCov.start do
  #         coverage_dir 'log/coverage'
  #         add_group "Shared" do |src_file|
  #           /lib\/dotruby\/v(\d+)(.*?)$/ !~ src_file.filename
  #         end
  #         add_group "Revision 0", "lib/dotruby/v0"
  #       end
  #     end
  #
  class Settings

    require 'tmpdir'
    require 'fileutils'

    # If files are not specified than these directories 
    # will be searched.
    DEFAULT_FILES = ['qed', 'demo', 'spec']

    # QED support configuration file mapping.
    #MAP_FILE = '.map'

    # Glob pattern used to search for project's root directory.
    ROOT_PATTERN = '{.map,.ruby,.git/,.hg/,_darcs/}'

    # Glob pattern used to find QED configuration file relative to root directory.
    CONFIG_PATTERN = '{.,,task/}qed,qedfile{,.rb}'

    # Home directory.
    HOME = File.expand_path('~')

    # Directory names to omit from automatic selection.
    OMIT_PATHS = %w{applique helpers support sample samples fixture fixtures}

    #
    # Initialize new Settings instance.
    #
    def initialize(options={})
      initialize_defaults
      initialize_configuration

      options.each do |key, val|
        send("#{key}=", val) if val
      end
    end

    #
    def initialize_defaults
      @files      = nil
      @format     = :dot
      @trace      = false
      @mode       = nil
      @profile    = ENV['profile'] || :default
      @loadpath   = ['lib']
      @requires   = []
      @omit       = OMIT_PATHS  # TODO: eventually make configurable
      @rootless   = false
    end

    #
    # QED can use either the Confection library for configuration,
    # task-style configuration files in the form of `task/<profile>.qed`,
    # or a traditional master `.qed` file.
    #
    # Note, that setting `ENV['confectionless']` will force Confection
    # not to be used. This is used by the Confection library so it can
    # run QED demos too.
    #
    def initialize_configuration
      @profiles = {}

      if confection_file && !ENV['confectionless']
        require 'confection'
        Confection.profiles(:qed).each do |name|
          @profiles[name.to_s] = lambda{ load_profile_from_confection(name) }
        end
      end

      Dir.glob(File.join(root, 'task/*.qed')).map do |file|
        name = File.basename(file).chomp('.qed')
        @profiles[name.to_s] = lambda{ load_profile_from_file(file) }
      end

      Dir.glob(File.join(root, '{.qed,.qed.rb,qed.rb,Qedfile}')).map do |file|
        @profiles[nil] = lambda{ load_profile_from_file(file) }
      end
    end

    # Lookup Confection config file.
    def confection_file
      Dir.glob(File.join(root, '{,.}confile{.rb,}'), File::FNM_CASEFOLD).first
    end

    # Demonstration files (or globs).
    def files
      @files ||= (
        [DEFAULT_FILES.find{ |d| File.directory?(d) }].compact
      )
    end

    #
    def files=(files)
      @files = Array(files).flatten.compact
    end

    # File patterns to omit.
    attr_accessor :omit

    # Output format.
    attr_accessor :format

    # Trace execution?
    attr_accessor :trace

    # Parse mode.
    attr_accessor :mode

    # Paths to be added to $LOAD_PATH.
    attr_accessor :loadpath

    # Libraries to be required.
    attr_accessor :requires

    # Operate from project root?
    attr_accessor :rooted

    # Operate from system temporary directory?
    attr_accessor :rootless

    # Selected profile.
    attr_accessor :profile

    #
    # Operate relative to project root directory, or use system's location.
    #
    def rootless?
      @rootless
    end

    #
    # Project's root directory.
    #
    def root
      @root ||= find_root
    end

    #
    # Alias for `#root`.
    #
    alias_method :root_directory, :root

    #
    # Temporary directory. If `#rootless?` return true then this will be
    # a system's temporary directory (e.g. `/tmp/qed/foo/20111117242323/`).
    # Otherwise, it will local to the project's root int `tmp/qed/`.
    #
    def temporary_directory
      @temporary_directory ||= (
        if rootless?
          system_tmpdir
        else
          File.join(root_directory, 'tmp', 'qed')
        end
        #FileUtils.mkdir_p(dir) unless File.directory?(dir)
      )
    end

    #
    # Shorthand for `#temporary_directory`.
    #
    alias_method :tmpdir, :temporary_directory

    #
    # Remove and recreate temporary working directory.
    #
    def clear_directory
      FileUtils.rm_r(tmpdir) if File.exist?(tmpdir)
      FileUtils.mkdir_p(tmpdir)
    end

    #
    # Define a profile.
    #
    # @deprecated Confection library is used instead.
    #
    # @param [#to_s] name
    #   Name of profile.
    #
    # @yield Procedure to run for profile.
    #
    # @return [Proc] The procedure.
    #
    #def profile(name, &block)
    #  raise "The #profile method is deprecated."
    #  #@profiles[name.to_s] = block
    #end

    #
    # Profiles are collected from the Confection library, unless 
    # confection is deactivated via the override file.
    # 
    def profiles
      @profiles.keys
    end

    #
    # Load QED configuration profile. The load procedure is stored as
    # a Proc object in a hash b/c different configuration systems
    # can be used.
    #
    def load_profile(profile)
      profile = @profiles[profile.to_s]
      profile.call if profile
    end

  private

    # TODO: find away to not need $ROOT global.

    #
    # Locate project's root directory. This is done by searching upward
    # in the file heirarchy for the existence of one of the following:
    #
    #   .ruby
    #   .git/
    #   .hg/
    #   _darcs/
    #   .qed
    #   .qed.rb
    #   qed.rb
    #
    # Failing to find any of these locations, resort to the fallback:
    # 
    #   lib/
    #
    # If that isn't found, then returns a temporary system location.
    # and sets `rootless` to true.
    #
    def find_root(path=nil)
      return ($ROOT = system_tmpdir) if @rootless

      path = File.expand_path(path || Dir.pwd)
      path = File.dirname(path) unless File.directory?(path)

      root = lookup(ROOT_PATTERN, path) || lookup(CONFIG_PATTERN, path)
      return root if root

      #root = lookup(path, '{qed,demo,spec}/')
      #return root if root

      root = lookup('lib/', path)

      if !root
        warn "QED is running rootless."
        system_tmpdir
        @rootless = true
      else
        root
      end

      $ROOT = root

      #abort "QED failed to resolve project's root location.\n" +
      #      "QED looks for following entries to identify the root:\n" +
      #      ROOT_PATTERN +
      #      "Please add one of them to your project to proceed."
    end

    # TODO: Use Dir.ascend from Ruby Facets.

    #
    # Lookup path +glob+, searching each higher directory
    # in turn until just before the users home directory
    # is reached or just before the system's root directory.
    #
    def lookup(glob, path=Dir.pwd)
      until path == HOME or path == '/' # until home or root
        mark = Dir.glob(File.join(path,glob), File::FNM_CASEFOLD).first
        return path if mark
        path = File.dirname(path)
      end
    end

    #
    # System-wide temporary directory for QED executation.
    #
    def system_tmpdir
      @system_tmpdir ||= (
        File.join(Dir.tmpdir, 'qed', File.basename(Dir.pwd), Time.new.strftime("%Y%m%d%H%M%S"))
      )
    end

    ##
    ## Return cached file map from a project's `.map` file, if it exists.
    ##
    #def file_map
    #  @file_map ||= (
    #    if File.exist?(map_file)
    #      YAML.load_file(map_file)
    #    else
    #      {}
    #    end
    #  )
    #end

    ##
    ## Lookup, cache and return `.map` map file.
    ##
    #def map_file
    #  @_map_file ||= File.join(root_directory,MAP_FILE)
    #end

    #
    def load_confection_profile(name)
      config = confection(:qed, name.to_sym)
      config.exec
    end

    #
    def load_profile_from_file(file)
      if File.exist?(file)
        instance_eval(File.read(file), file)
      else
        # raise "no profile -- #{profile}"
      end
    end

  end

end
