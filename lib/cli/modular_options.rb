require 'optparse'

module CLI
  
  # Use 'extend CLI::WithOptions' to declare OptionParser configuration blocks in your module.
  module WithOptions
    # Used to declare a proc that can be used to configure an instance of OptionParser with a
    # class or module.
    def cli_options( &block )
      raise ArgumentError, 'Block required but not given' unless block_given?
      (@cli_options_hooks ||= Array.new) << block
    end
  end # WithOptions
  
  # Use 'include CLI::ModularOptions' in a class whose instances will consume procs declared
  # using CLI::WithOptions#cli_options to configure instances of OptionParser.
  module ModularOptions
    # Constructs a new instance of OptionParser and configures it using the cli_options blocks
    # declared in modules found in the inheritance chain of a class or module.  If a class or
    # module is not specified, the class of self is assumed.
    #
    # @param mod [Class, Module] Optional, take cli_options from a different class
    # @return [OptionParser] configured parser instance
    def new_cli_parser( mod = self.class )
      OptionParser.new do |p|
        configure_cli_parser p, CLI::ModularOptions.ancestral_hooks(mod)
      end
    end
    
    # Configures a given parser by passing it to the given hook procs, which are called in the
    # context of self
    #
    # @param parser [OptionParser] the parser to be configured
    # @param hooks [Array<Proc>] parser configuration procs declared with cli_options
    def configure_cli_parser( parser, hooks )
      hooks.each do |b|
        instance_exec parser, &b
      end
    end
    
    # Get parser configuration procs belonging to the specified modules.  Inheritance is not considered.
    #
    # @param modules list of classes and modules that may or may not have cli_options procs
    # @return [Array<Proc>] all cli_options procs belonging to specified modules
    def self.hooks_from( *modules )
      modules.map{ |m|
        m.instance_variable_get :@cli_options_hooks if m.instance_variable_defined? :@cli_options_hooks
      }.flatten.compact
    end
    
    # Get parser configuration procs belonging to or inherited by the specified class or module.
    #
    # @param mod [Class, Module]
    # @return [Array<Proc>]
    def self.ancestral_hooks( mod )
      hooks_from(*mod.ancestors.uniq.reverse)
    end
  end # ModularOptions

end # CLI
