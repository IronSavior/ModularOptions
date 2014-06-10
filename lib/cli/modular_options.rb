require 'optparse'

module CLI
  
  module WithOptions
    def cli_options( &block )
      raise ArgumentError, 'Block required but not given' unless block_given?
      const_set :CLI_OPTS_HOOKS, Array.new unless const_defined? :CLI_OPTS_HOOKS, false
      const_get(:CLI_OPTS_HOOKS) << block
    end
  end # WithOptions
  
  module ModularOptions
    def cli_opts
      @cli_opts ||= Hash.new
    end
    
    def new_options_parser
      OptionParser.new do |p|
        self.class.cli_hooks.each{ |b| instance_exec p, cli_opts, &b }
      end
    end
    
    def parse_options!( argv )
      cli_opts[:positional] = new_options_parser.parse! argv
    end
    
    def self.included( base )
      base.extend ClassMethods
      super
    end
    
    module ClassMethods
      def ancestors_with_cli_hooks
        ancestors.select{ |m| m.const_defined? :CLI_OPTS_HOOKS, false }
      end
      
      def cli_hooks
        ancestors_with_cli_hooks.map{ |m| m::CLI_OPTS_HOOKS }.reverse.flatten
      end
    end # ClassMethods
  end # ModularOptions

end # CLI
