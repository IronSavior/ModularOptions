require 'cli/modular_options'

module TestModel
  def self.new_cli_hook( mod, name )
    k = name.to_s.downcase.to_sym
    mod.instance_eval do
      cli_options do |p|
        cfg[:context]    << self.class
        cfg[:call_order] << name.to_s
        cfg[k] = false
        p.on "--#{k}" do
          cfg[k] = true
        end
      end
    end
  end
  
  def self.new_module( args = {} )
    args = {
      :name        => 'TestMod',
      :add_options => true
    }.merge args
    Module.new do
      extend CLI::WithOptions
      TestModel.new_cli_hook self, args[:name] if args[:add_options]
    end
  end
  
  def self.new_class( args = {} )
    args = {
      :base            => Object,
      :modular_options => false,
      :with_options    => false,
      :name            => 'TestClass',
      :feature_modules =>  Array.new
    }.merge args
    
    Class.new args[:base] {
      if args[:modular_options]
        include CLI::ModularOptions
        
        define_method :inherit_options_from do
          args[:inherit_options_from] || self.class
        end
        
        def cfg
          @cfg ||= Hash.new
        end
        
        def initialize( argv = [] )
          cfg[:context]    = Array.new
          cfg[:call_order] = Array.new
          cfg[:positional] = new_cli_parser(inherit_options_from).parse! argv
        end
      end
      
      args[:feature_modules].each do |m|
        include m.kind_of?(Module)? m : TestModel.new_module(:name => m)
      end
      
      if args[:with_options]
        extend CLI::WithOptions
        TestModel.new_cli_hook self, args[:name]
      end
    }
  end
end
