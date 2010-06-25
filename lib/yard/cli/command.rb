require 'optparse'

module YARD
  module CLI
    # Abstract base class for CLI utilities. Provides some helper methods for
    # the option parser
    # 
    # @abstract
    class Command
      # Helper method to run the utility on an instance.
      # @see #run
      def self.run(*args) new.run(*args) end
        
      def description; '' end
          
      protected

      # Adds a set of common options to the tail of the OptionParser
      # 
      # @param [OptionParser] opts the option parser object
      # @return [void]
      def common_options(opts)
        opts.separator ""
        opts.separator "Other options:"
        opts.on('-e', '--load FILE', 'A Ruby script to load before the source tree is parsed.') do |file|
          if !require(file.gsub(/\.rb$/, ''))
            log.error "The file `#{file}' was already loaded, perhaps you need to specify the absolute path to avoid name collisions."
            exit
          end
        end
        opts.on('--legacy', 'Use old style Ruby parser and handlers. Always on in 1.8.x.') do
          YARD::Parser::SourceParser.parser_type = :ruby18
        end
        opts.on_tail('-q', '--quiet', 'Show no warnings.') { log.level = Logger::ERROR }
        opts.on_tail('--verbose', 'Show more information.') { log.level = Logger::INFO }
        opts.on_tail('--debug', 'Show debugging information.') { log.level = Logger::DEBUG }
        opts.on_tail('--backtrace', 'Show stack traces') { log.show_backtraces = true }
        opts.on_tail('-v', '--version', 'Show version.') { puts "yard #{YARD::VERSION}"; exit }
        opts.on_tail('-h', '--help', 'Show this help.')  { puts opts; exit }
      end
    
      # Parses the option and gracefully handles invalid switches
      # 
      # @param [OptionParser] opts the option parser object
      # @param [Array<String>] args the arguments passed from input. This
      #   array will be modified.
      # @return [void]
      def parse_options(opts, args)
        opts.parse!(args)
      rescue OptionParser::InvalidOption => e
        log.warn "Unrecognized/#{e.message}"
      end
    end
  end
end