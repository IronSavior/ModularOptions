module TestModels
  def self.new_module( mname, add_options = true )
    kname = mname.to_s.downcase.to_sym
    Module.new do
      extend CLI::WithOptions
      
      if add_options
        cli_options do |p, cfg|
          cfg[:order] ||= Array.new
          cfg[:order] << mname.to_s
          cfg[kname] ||= false
          p.on "--#{kname}" do
            cfg[kname] = true
          end
        end
      end
    end
  end
  
  def self.new_class( args = {} )
    args = {
      base: Object,
      modular_options: false,
      with_options: false,
      name: 'App',
      feature_modules: Array.new
    }.merge args
    kname = args[:name].downcase.to_sym
    
    Class.new args[:base] do
      if args[:modular_options]
        include CLI::ModularOptions
        def initialize( argv )
          parse_options! argv
        end
      end
      
      args[:feature_modules].each do |m|
        include m.kind_of?(Module)? m : TestModels.new_module(m)
      end
      
      if args[:with_options]
        extend CLI::WithOptions
        cli_options do |p, cfg|
          cfg[:order] ||= Array.new
          cfg[:order] << args[:name].to_s
          p.on "--#{kname}" do
            cfg[kname] = true
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
end
