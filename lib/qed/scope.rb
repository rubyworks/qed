module QED

  require 'ae'
  require 'qed/advice'

  #--
  # TODO: Replace Scope for TOPLEVEL?
  #++
  class Scope

    include Advisable

    def __binding__
      @__binding__ ||= binding
    end

    # Table-based steps.
    #--
    # TODO: Utilize HTML table element for tables.
    #++
    def Table(file=nil, &blk)
      file = file || @_tables.last
      tbl = YAML.load(File.new(file))
      tbl.each do |set|
        blk.call(*set)
      end
      @__tables__ ||= []
      @__tables__ << file
    end

    # Read/Write a static data fixture.
    #--
    # TODO: Perhaps #Data would be best as some sort of Kernel extension.
    #++
    def Data(file, &content)
      raise if File.directory?(file)
      if content
        FileUtils.mkdir_p(File.dirname(fname))
        case File.extname(file)
        when '.yml', '.yaml'
          File.open(file, 'w'){ |f| f << content.call.to_yaml }
        else
          File.open(file, 'w'){ |f| f << content.call }
        end
      else
        #raise LoadError, "no such fixture file -- #{fname}" unless File.exist?(fname)
        case File.extname(file)
        when '.yml', '.yaml'
          YAML.load(File.new(file))
        else
          File.read(file)
        end
      end
    end

    # Code match-and-transform procedure.
    #
    # This is useful to transform human readable code examples
    # into proper exectuable code. For example, say you want to
    # run shell code, but want to make if look like typical
    # shelle examples:
    #
    #    $ cp fixture/a.rb fixture/b.rb
    #
    # You can use a transform to convert lines starting with '$'
    # into executable Ruby using #system.
    #
    #    system('cp fixture/a.rb fixture/b.rb')
    #
    #def Transform(pattern=nil, &procedure)
    #
    #end

  end

end

