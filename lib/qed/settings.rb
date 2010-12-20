module QED

  # Ecapsulate confiduration information needed for QED
  # run and set user and project options.
  class Settings

    require 'tmpdir'
    require 'fileutils'

    # Configuration directory `.qed`, `.config/qed` or `config/qed`.
    # In this directory special configuration files can be placed
    # to autmatically effect qed execution. In particular you can
    # add a `profiles.yml` file to setup convenient execution
    # scenarios.
    CONFIG_PATTERN = "{.,.set/,set/.config/,config/}qed"

    # Glob pattern used to search for project's root directory.
    ROOT_PATTERN = '{.ruby,.git/,.hg/,_darcs/,.qed/,.set/qed/,set/qed/.config/qed/,config/qed/}'

    # Home directory.
    HOME = File.expand_path('~')

    #
    def initialize(options={})
      @rootless = options[:rootless]
    end

    #
    def rootless?
      @rootless
    end

    # Project's root directory.
    def root_directory
      @root_directory ||= find_root
    end

    # Project's QED configuration directory.
    # TODO: rename to `config_directory` ?
    def settings_directory
      @settings_directory ||= find_settings
    end

    #
    def temporary_directory
      @temporary_directory ||= (
        if rootless?
          File.join(Dir.tmpdir, 'qed', File.filename(Dir.pwd), Time.new.strftime("%Y%m%d%H%M%S"))
        else
          File.join(root_directory, 'tmp', 'qed')
        end
        #FileUtils.mkdir_p(dir) unless File.directory?(dir)
      )
    end

    #
    alias_method :tmpdir, :temporary_directory

    # Remove and recreate temporary working directory.
    def clear_directory
      FileUtils.rm_r(tmpdir) if File.exist?(tmpdir)
      FileUtils.mkdir_p(tmpdir)
    end

    # Profile configurations.
    def profiles
      @profiles ||= (
        files = Dir["#{settings_directory}/*.rb"]
        files.map do |file|
          File.basename(file).chomp('.rb')
        end
      )
    end

    # Require requirement file (from -e option).
    def require_profile(profile)
      return unless settings_directory
      if file = Dir["#{settings_directory}/#{profile}.rb"].first
        require(file)
      end
    end

    # Locate project's root directory. This is done by searching upward
    # in the file heirarchy for the existence of one of the following
    # path names, each group being tried in turn.
    #
    # * .git/
    # * .hg/
    # * _darcs/
    # * .config/qed/
    # * config/qed/
    # * .qed/
    # * .ruby
    #
    # Failing to find any of these locations, resort to the fallback:
    # 
    # * lib/
    #
    def find_root(path=nil)
      path = File.expand_path(path || Dir.pwd)
      path = File.dirname(path) unless File.directory?(path)

      root = lookup(ROOT_PATTERN, path)
      return root if root

      #root = lookup(path, '{.qed,.config/qed,config/qed}/')
      #return root if root

      #root = lookup(path, '{qed,demo,demos}/')
      #return root if root

      root = lookup('lib/', path)

      return root if root

      abort "QED failed to resolve project's root location.\n" +
            "QED looks for following entries to identify the root:\n" +
            "  .set/qed/\n" +
            "  set/qed/\n" +
            "  .config/qed/\n" +
            "  config/qed/\n" +
            "  .qed/\n" +
            "  .ruby\n" +
            "  lib/\n" +
            "Please add one of them to your project to proceed."
    end

    # Locate configuration directory by seaching up the 
    # file hierachy relative to the working directory
    # for one of the following paths:
    #
    # * .config/qed/
    # *  config/qed/
    # * .qed/
    #
    def find_settings
      Dir[File.join(root_directory,CONFIG_PATTERN)].first
    end

    # Lookup path +glob+, searching each higher directory
    # in turn until just before the users home directory
    # is reached or just before the system's root directory.
    #
    # TODO: include HOME directory in search?
    def lookup(glob, path=Dir.pwd)
      until path == HOME or path == '/' # until home or root
        mark = Dir.glob(File.join(path,glob), File::FNM_CASEFOLD).first
        return path if mark
        path = File.dirname(path)
      end
    end

  end

end
