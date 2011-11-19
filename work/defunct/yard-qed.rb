module YARD::CodeObjects
  class QEDFileObject < ExtraFileObject
    #
    def initialize(dirname)
      self.filename = dirname
      self.name = File.basename(filename).gsub(/\.[^.]+$/, '').upcase
      self.attributes = SymbolHash.new(false)

      files = Dir["#{dirname}/**/*{.rdoc,.md,.qed,.markdown}"]
      files = files.reject{ |f| File.directory?(f) }
      files = files.sort
      contents = files.map{ |f| File.read(f) }.join("\n\n")

      parse_contents(contents)
    end
  end
end

module YARD
  module CLI
    class Yardoc
      alias run_without_qed run
      def run(*args)
        dir = Dir['{qed/,demo/,spec/}'].first.chomp('/')
        @options[:files] << CodeObjects::QEDFileObject.new(dir)
        run_without_qed(*args)
      end
    end
  end
end

