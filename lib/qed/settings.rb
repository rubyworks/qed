module QED

  # Ecapsulate configuration information needed for QED to
  # run and set user and project options.
  #
  # Configuration for QED is place in a .config.rb or config.rb file.
  # In this file special configuration setups can be placed
  # to automatically effect QED execution.
  #
  #   qed do
  #     profile :cov do
  #       require 'simplecov'
  #       SimpleCov.start do
  #         coverage_dir 'log/coverage'
  #         add_group "Shared" do |src_file|
  #           /lib\/dotruby\/v(\d+)(.*?)$/ !~ src_file.filename
  #         end
  #         add_group "Revision 0", "lib/dotruby/v0"
  #       end
  #     end
  #   end
  # 
  class Settings

    require 'tmpdir'
    require 'fileutils'
    require 'confection'


    # Glob pattern used to search for project's root directory.
    ROOT_PATTERN = '{.config.rb,config.rb,.ruby,.git/,.hg/,_darcs/,lib/}'

    # Home directory.
    HOME = File.expand_path('~')

    #
    def initialize(options={})
      @rootless = options[:rootless]
      @profiles = {}

      confection('qed').exec
    end

    attr_accessor :rootless

    #
    def rootless?
      @rootless
    end

    # Project's root directory.
    def root_directory
      @root_directory ||= find_root
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

    # Define a profile.
    def profile(name, &block)
      @profiles[name.to_s] = block
    end

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

    # Load QED profile (from -e option).
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
            ROOT_PATTERN +
            "Please add one of them to your project to proceed."
    end

    ## Locate configuration directory by seaching up the 
    ## file hierachy relative to the working directory
    ## for one of the following paths:
    ##
    ## * .config/qed/
    ## *  config/qed/
    ## * .qed/
    ##
    #def find_settings
    #  Dir[File.join(root_directory,CONFIG_PATTERN)].first
    #end

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
