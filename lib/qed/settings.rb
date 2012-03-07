module QED

  # Settings ecapsulates setup code for running QED.
  #
  # By convention, configuration for QED is placed in `task/qed.rb`.
  # Configuration may also be placed at project root level in `qed.rb`,
  # or if you're old-school, a `.qed` hidden file can still be used. If you
  # don't like any of these choices, QED supports configuration file mapping
  # via the `.map` file. Just add a `qed: path/to/qed/config/file` entry.
  #
  # In this file special configuration setups can be placed to automatically
  # effect QED execution, in particular optional profiles can be defined.
  #
  #     profile :coverage do
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

    # QED support configuration file mapping.
    MAP_FILE = '.map'

    # Glob pattern used to search for project's root directory.
    ROOT_PATTERN = '{.map,.ruby,.git/,.hg/,_darcs/,.qed,.qed.rb,qed.rb,task/qed.rb}'

    # Glob pattern used to find QED configuration file in root directory.
    CONFIG_PATTERN = '{task/qed.rb,qed.rb,.qed,.qed.rb}'

    # Home directory.
    HOME = File.expand_path('~')

    #
    #
    #
    def initialize(options={})
      @rootless = options[:rootless]
      @profiles = {}

      @root = @rootless ? system_tmpdir : find_root

      # Set global. TODO: find away to not need this ?
      $ROOT = @root

      if config_file
        instance_eval(File.read(config_file), config_file)
      end
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
    def root_directory
      @root
    end

    #
    # Shorthand for `#root_directory`.
    #
    alias_method :root, :root_directory

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
    # @param [#to_s] name
    #   Name of profile.
    #
    # @yield Procedure to run for profile.
    #
    # @return [Proc] The procedure.
    #
    def profile(name, &block)
      @profiles[name.to_s] = block
    end

    #
    # Keeps a list of defined profiles.
    #
    attr_accessor :profiles

    # Profile configurations.
    #def profiles
    #  @profiles ||= (
    #    files = Dir["#{settings_directory}/*.rb"]
    #    files.map do |file|
    #      File.basename(file).chomp('.rb')
    #    end
    #  )
    #end

    #
    # Load QED profile (from -e option).
    #
    def load_profile(name)
      if profile = profiles[name.to_s]
        instance_eval(&profile)
        #eval('self', TOPLEVEL_BINDING).instance_eval(&prof)
      end
      #return unless settings_directory
      #if file = Dir["#{settings_directory}/#{profile}.rb"].first
      #  require(file)
      #end
    end

    #
    # Locate project's root directory. This is done by searching upward
    # in the file heirarchy for the existence of one of the following:
    #
    #   .map
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
      path = File.expand_path(path || Dir.pwd)
      path = File.dirname(path) unless File.directory?(path)

      root = lookup(ROOT_PATTERN, path)
      return root if root

      #root = lookup(path, '{qed,demo,spec}/')
      #return root if root

      root = lookup('lib/', path)

      if !root
        warn "QED is running rootless."
        root = system_tmpdir
        @rootless = true
      end

      return root

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

    #
    # Lookup, cache and return QED config file.
    #
    def config_file
      @config_file ||= (
        glob = file_map['qed'] || CONFIG_PATTERN
        Dir.glob(File.join(root_directory,glob)).first
      )
    end

    #
    # Return cached file map from a project's `.map` file, if it exists.
    #
    def file_map
      @file_map ||= (
        if File.exist?(map_file)
          YAML.load_file(map_file)
        else
          {}
        end
      )
    end

    #
    # Lookup, cache and return `.map` map file.
    #
    def map_file
      @_map_file ||= File.join(root_directory,MAP_FILE)
    end

  end

end
