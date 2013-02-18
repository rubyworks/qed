require 'qed/configure'
require 'qed/utils'

module QED

  # Settings ecapsulates setup configuration for running QED.
  #
  class Settings

    require 'tmpdir'
    require 'fileutils'

    # If files are not specified than these directories 
    # will be searched.
    DEFAULT_FILES = ['qed', 'demo', 'spec']

    # Directory names to omit from automatic selection.
    OMIT_PATHS = %w{applique helpers support sample samples fixture fixtures}

    #
    # Initialize new Settings instance.
    #
    def initialize(options={}, &block)
      initialize_defaults

      @profile = (options.delete(:profile) || default_profile).to_s

      load_profile(&block)

      options.each do |key, val|
        send("#{key}=", val) if val
      end
    end

    #
    # Initialize default settings.
    #
    def initialize_defaults
      @files    = nil #DEFAULT_FILES
      @format   = :dot
      @trace    = false
      @mode     = nil  # ?
      @loadpath = ['lib']
      @omit     = OMIT_PATHS
      @rootless = false
      @requires = []
      #@profile  = :default
    end

    # Profile name can come from `profile` or `p` environment variables.
    def default_profile
      ENV['profile'] || ENV['p'] || 'default'
    end

    # Demonstration files (or globs).
    def files
      @files ||= (
        [DEFAULT_FILES.find{ |d| File.directory?(d) }].compact
      )
    end

    #
    def files=(files)
      @files = (
        if files.nil? or files.empty?
          nil
        else
          Array(files).flatten.compact
        end
      )
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

    #
    # Load QED configuration profile. The load procedure is stored as
    # a Proc object in a hash b/c different configuration systems
    # can be used.
    #
    def load_profile(&block)
      config = QED.profiles[@profile]
      config.call(self) if config
    end

    #
    # Profiles are collected from the RC library, unless 
    # RC is deactivated via the override file.
    # 
    def profiles
      QED.profiles.keys
    end

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
      Utils.root
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
          Utils.system_tmpdir
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

=begin
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
    def profile(name=nil, &block)
      return @profile unless name
      return @profile[name.to_s] unless block
      @profiles[name.to_s] = block
    end
=end

  private

    # TODO: Support .map in future ?

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
    #def load_confection_profile(name)
    #  config = confection(:qed, name.to_sym)
    #  config.exec
    #end

  end

end

