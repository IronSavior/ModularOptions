module TestModels
  def self.new_test_hook( mod, name )
    k = name.to_s.downcase.to_sym
    mod.instance_eval do
      cli_options do |p, cfg|
        cfg[:call_order] ||= Array.new
        cfg[:call_order] << name.to_s
        cfg[k] ||= false
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
      TestModels.new_test_hook self, args[:name] if args[:add_options]
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
    
    Class.new args[:base] do
      if args[:modular_options]
        include CLI::ModularOptions
        def initialize( argv = [] )
          parse_options! argv
        end
      end
      
      args[:feature_modules].each do |m|
        include m.kind_of?(Module)? m : TestModels.new_module(:name => m)
      end
      
      if args[:with_options]
        extend CLI::WithOptions
        TestModels.new_test_hook self, args[:name]
      end
    end
  end
end

RSpec.configure do |config|
end
