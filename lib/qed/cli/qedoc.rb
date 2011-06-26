module QED

  require 'optparse'
  require 'qed/document'

  class Document

    # Command line interface for generating qedocs.
    def self.cli(*argv)

      options = {}

      parser = OptionParser.new do |usage|
        usage.banner = "Usage: qedoc [OPTIONS] <QEDFile1> [ <QEDFile2> ... ]"

        usage.on("-o", "--output [DIR]", "Output directory") do |dir|
          options[:output]= dir
        end

        usage.on("-t", "--title [TITLE]", "Title of Document") do |title|
          options[:title]= title
        end

        usage.on("--css [URI]", "Specify a URI for a CSS file add to HTML header.") do |uri|
          options[:css] = uri
        end

        usage.on("--dryrun", "") do
          options[:dryrun] = true
        end

        usage.on("-q", "--quiet", "") do
          options[:quiet] = true
        end

        usage.on_tail("-h", "--help", "display this help message") do
          puts usage
          exit
        end
      end

      parser.parse!(argv)

      options[:paths] = argv.dup

      #opts[:output] = cli.options[:file]
      #opts[:dryrun] = cli.options[:dryrun]
      #opts[:quiet]  = cli.options[:quiet]
      #opts[:css]    = cli.options[:css]
      #opts[:title]  = cli.options[:title]

      doc = QED::Document.new(options)

      doc.generate
    end

  end

end
