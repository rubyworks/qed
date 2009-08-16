module Quarry

  # = Exception Break and Edit
  #
  class Break

    attr :exception

    alias_method :error, :exception

    #
    def initialize(exception)
      @exception = exception
    end

    #
    def edit
      file, line = *exception.backtrace[0].split(':')
      line = line.to_i

      puts exception

      e = "# DEBUG " + exception.to_s
      e.gsub!("`","'")

      e = Regexp.escape(e)

      case ed = ENV['EDITOR']
      when 'vi', 'vim', 'gvim'
        cmd = []
        cmd << "#{ed} -e -s #{file} <<-EOS"
        cmd << ":#{line}"
        cmd << "a"
        cmd << "#{e}"
        cmd << "."
        cmd << ":.,+#{e.size}"
        cmd << "EOS"
        cmd = cmd.join("\n")
      when nil
        puts "EDITOR environment variable not set"
      else
        puts "EDITOR environment variable not supported"
      end

      system cmd
    end

  end #class Break

end #module Quarry

