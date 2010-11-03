module QED

  #require 'qed/config'
  require 'qed/applique'
  require 'qed/demo'

  # = Runtime Session
  #
  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

    # Demonstration files.
    attr :files

    # Output format.
    attr_accessor :format

    # Trace mode
    attr_accessor :trace

    #
    attr_accessor :mode

    # New Session
    def initialize(files, options={})
      require_reporters

      @files  = [files].flatten

      @mode   = options[:mode]
      @trace  = options[:trace]  || false
      @format = options[:format] || :dotprogress

      #options.each do |k,v|
      #  __send__("#{k}=", v) if v
      #end

      @applique = create_applique
    end

    #
    def applique
      @applique
    end

    # Top-level configuration.
    #def config
    #  QED.config
    #end

    # TODO: Ultimately use Plugin library to support custom reporters?
    def require_reporters
      Dir[File.dirname(__FILE__) + '/reporter/*'].each do |file|
        require file
      end
    end

    # Instance of selected Reporter subclass.
    def reporter
      @reporter ||= (
        name = Reporter.constants.find{ |c| /#{format}/ =~ c.downcase }
        Reporter.const_get(name).new(:trace => trace)
      )
    end

    #
    #def scope
    #  @scope ||= Scope.new
    #end

    # TODO: switch order of applique and file.
    def demos
      @demos ||= files.map{ |file| Demo.new(file, applique, :mode=>mode) }
    end

    #
    def observers
      [reporter]
    end

    # Run session.
    def run
      #profile.before_session(self)
      reporter.before_session(self)
      #demos.each do |demo|
      #  script = Demo.new(demo, report)
      demos.each do |demo|
        demo.run(*observers)
        #pid = fork { script.run(*observers) }
        #Process.detach(pid)
       end
      reporter.after_session(self)
      #profile.after_session(self)
    end

    # Globally applicable advice.
    #def environment
    #  scripts.each do |script|
    #    script.require_environment
    #  end
    #end

    # TODO: associate scripts to there applique ?
    def create_applique
      applique = Applique.new
      #eval "include QED::DomainLanguage", TOPLEVEL_BINDING
      applique_scripts.each do |file|
        #next if @loadlist.include?(file)
        #case File.extname(file)
        #when '.rb'
          # since scope is just TOPLEVEL now
          #require(file)
          applique.module_eval(File.read(file), file)
          #eval(File.read(file), scope.__binding__, file)  # TODO: for each script!? Nay.
        #else
        #  Script.new(file, scope).run
        #end
        #@loadlist << file
      end
      applique
    end

    # SCM: reverse order of applique so topmost directory comes first
    def applique_scripts
      locs = []
      files.each do |file|
        Dir.ascend(File.dirname(file)) do |path|
          break if path == Dir.pwd
          dir = File.join(path, 'applique')
          if File.directory?(dir)
            locs << dir
          end
        end
      end
      envs = locs.reverse.map{ |loc| Dir[File.join(loc,'**/*.rb')] }
      envs.flatten.compact.uniq
    end

  end#class Session

end#module QED
