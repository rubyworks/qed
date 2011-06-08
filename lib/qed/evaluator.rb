module QED

  require 'qed/scope'

  # = Demonstrandum Evaluator
  class Evaluator

    #
    def initialize(script, *observers)
      @script  = script
      @steps   = script.parse

      #@file    = script.file
      #@scope   = script.scope
      #@binding = script.binding
      #@advice  = script.advice

      @observers = observers
    end

    #
    def run
      advise!(:before_demo, @script)
      advise!(:demo, @script)
      run_steps
      advise!(:after_demo, @script)
    end

    #
    def run_steps #process
      @steps.each do |step|
        evaluate(step)
      end
    end

    #
    def evaluate(step)
      type = step.type
      advise!(:before_step, step) #, @script.file)
      advise!("before_#{type}".to_sym, step) #, @script.file)
      case type
      when :head
        evaluate_head(step)
      when :desc
        evaluate_desc(step)
      when :data
        evaluate_data(step)
      when :code
        evaluate_code(step)
      else
        raise "fatal: unknown #{type}"
      end
      advise!("after_#{type}".to_sym, step) #, @script.file)
      advise!(:after_step, step) #, @script.file)
    end

    #
    def evaluate_head(step)
      advise!(:head, step)
    end

    #
    def evaluate_desc(step)
      evaluate_links(step)
      begin
        advise!(:desc, step)
        advise!(:when, step) # triggers matchers
      rescue SystemExit
        pass!(step)
      #rescue Assertion => exception
      #  fail!(step, exception)
      rescue Exception => exception
        if exception.assertion?
          fail!(step, exception)
        else
          error!(step, exception)
        end
      else
        pass!(step)
      end
    end

    #
    def evaluate_data(step)
      #advise!(:data, step)
      begin
        advise!(:data, step)
      rescue SystemExit
        pass!(step)
      #rescue Assertion => exception
      #  fail!(step, exception)
      rescue Exception => exception
        if exception.assertion?
          fail!(step, exception)
        else
          error!(step, exception)
        end
      else
        pass!(step)
      end
    end

    # Evaluate a demo step.
    def evaluate_code(step)
      begin
        advise!(:code, step)
        @script.evaluate(step.code, step.lineno)
      rescue SystemExit
        pass!(step)  # TODO: skip!(step)
      #rescue Assertion => exception
      #  fail!(step, exception)
      rescue Exception => exception
        if exception.assertion?
          fail!(step, exception)
        else
          error!(step, exception)
        end
      else
        pass!(step)
      end
    end

    # TODO: Not sure how to handle loading links in --comment runner mode.
    # TODO: Do not think Scope should be reuseud by imported demo.
    def evaluate_links(step)
      step.text.scan(/\[qed:\/\/(.*?)\]/) do |match|
        file = $1
        # relative to demo script
        if File.exist?(File.join(@script.directory,file))
          file = File.join(@script.directory,file)
        end
        # ruby or another demo
        case File.extname(file)
        when '.rb'
          import!(file)
        else
          Demo.new(file, :scope=>@script.scope).run
        end
      end
    end

    #
    def pass!(step)
      advise!(:pass, step)
    end

    #
    def fail!(step, exception)
      advise!(:fail, step, exception)
      #raise exception
    end

    #
    def error!(step, exception)
      advise!(:error, step, exception)
      #raise exception
    end

    #
    def import!(file)
      advise!(:unload) # should this also occur just befor after_demo ?
      eval(File.read(file), @script.binding, file)
      advise!(:load, file)
    end

    # Dispatch event to observers and advice.
    def advise!(signal, *args)
      @observers.each{ |o| o.update(signal, *args) }

      #@script.advise(signal, *args)
      case signal
      when :when
        call_matchers(*args)
      else
        call_signals(signal, *args)
      end
    end

    #
    #def advise_when!(match)
    #  @advice.call_when(match)
    #end

    # React to an event.
    #
    # TODO: Should events short circuit on finding first match?
    # In other words, should there be only one of each type of signal
    # ragardless of how many applique layers?
    def call_signals(type, *args)
      @script.applique.each do |a|
        signals = a.__signals__
        proc = signals[type.to_sym] 
        #signals.each do |set|
          #proc = set[type.to_sym]
          #proc.call(*args) if proc
          @script.scope.instance_exec(*args, &proc) if proc
        #end
      end

      #@script.applique.each do |a|
      #  signals = a.__signals__
      #  proc = signals[type.to_sym] 
      #  if proc
      #    @script.scope.instance_exec(*args, &proc)
      #    break
      #  end
      #end

      #meth = "qed_#{type}"
      #if @script.scope.respond_to?(meth)
      #  meth = @script.scope.method(meth)
      #  if meth.arity == 0
      #    meth.call
      #  else
      #    meth.call(*args)
      #  end
      #end

      #@script.scope.__send__(meth, *args)
    end

    #
    def call_matchers(section)
      match = section.text
      args  = section.arguments
      @script.applique.each do |a|
        matchers =  a.__matchers__
        matchers.each do |(patterns, proc)|
          compare = match
          matched = true
          params  = []
          patterns.each do |pattern|
            case pattern
            when Regexp
              regex = pattern
            else
              regex = match_string_to_regexp(pattern)
            end
            if md = regex.match(compare)
              params.concat(md[1..-1])
              compare = md.post_match
            else
              matched = false
              break
            end
          end
          if matched
            params += args
            #proc.call(*params)
            @script.scope.instance_exec(*params, &proc)
          end
        end
      end
    end

    # Convert matching string into a regular expression. If the string
    # contains double parenthesis, such as ((.*?)), then the text within
    # them is treated as in regular expression and kept verbatium.
    #
    # TODO: Better way to isolate regexp. Maybe ?:(.*?) or /(.*?)/.
    #
    # TODO: Now that we can use multi-patterns, do we still need this?
    #
    def match_string_to_regexp(str)
      str = str.split(/(\(\(.*?\)\))(?!\))/).map{ |x|
        x =~ /\A\(\((.*)\)\)\Z/ ? $1 : Regexp.escape(x)
      }.join
      str = str.gsub(/\\\s+/, '\s+')
      Regexp.new(str, Regexp::IGNORECASE)

      #rexps = []
      #str = str.gsub(/\(\((.*?)\)\)/) do |m|
      #  rexps << '(' + $1 + ')'
      #  "\0"
      #end
      #str = Regexp.escape(str)
      #rexps.each do |r|
      #  str = str.sub("\0", r)
      #end
      #str = str.gsub(/(\\\ )+/, '\s+')
      #Regexp.new(str, Regexp::IGNORECASE)
    end

    ##
    #def method_missing(s, *a)
    #  super(s, *a) unless /^tag/ =~ s.to_s
    #end

  end

end
