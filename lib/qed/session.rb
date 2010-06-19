module QED

  #require 'qed/config'
  require 'qed/applique'
  require 'qed/script'

  # = Runtime Session
  #
  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

    # Demonstration files.
    attr :demos

    # Output format.
    attr_accessor :format

    # Trace mode
    attr_accessor :trace

    # New demonstration
    def initialize(demos, options={})
      require_reporters

      @demos  = [demos].flatten

      @format = :dotprogress
      @trace  = false

      options.each do |k,v|
        __send__("#{k}=", v) if v
      end

      @applique = create_applique
    end

    # Top-level configuration.
    #def config
    #  QED.config
    #end

    # TODO: Ultimately use Plugin library.
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

    #
    def scripts
      @scripts ||= demos.map{ |demo| Script.new(@applique, demo) }
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
      #  script = Script.new(demo, report)
      scripts.each do |script|
        script.run(*observers)
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

    # TODO: associate scripts to there applique
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

    #
    def applique_scripts
      locs = []
      demos.each do |demo|
        Dir.ascend(File.dirname(demo)) do |path|
          break if path == Dir.pwd
          dir = File.join(path, 'applique')
          if File.directory?(dir)
            locs << dir
          end
        end
      end
      envs = locs.map{ |loc| Dir[File.join(loc,'**/*.rb')] }
      envs.flatten.compact.uniq
    end

  end#class Session

end#module QED

