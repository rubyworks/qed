module QED

  # Glob pattern used to search for project's root directory.
  ROOT_PATTERN = '{.ruby*,.git/,.hg/,_darcs/}'

  # Glob pattern for standard config file.
  CONFIG_PATTERN = '{etc/qed.rb,config/qed.rb,Qedfile,.qed}'

  # Home directory.
  HOME = File.expand_path('~')

  #
  module Utils
    extend self

    #
    def load_config
      load_etc unless ENV['noetc']
      load_rc  unless ENV['norc']
    end

    #
    def load_rc
      rc_file= File.join(root, '.rubyrc')
      if File.exist?(rc_file)
        begin
          require 'rc/api'
          RC.profile_switch 'qed', '-p', '--profile'
          RC.configure 'qed' do |config|
            QED.configure(config.profile, &config)
          end
        rescue LoadError
        end
      end
    end

    #
    def load_etc
      file = Dir.glob(File.join(root, CONFIG_PATTERN)).first
      if file
        load file
      end
    end

    #
    def root
      @root ||= find_root
    end

    # TODO: find a way to not need $ROOT global.

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

  end

end
