require './lib/cli/modular_options'
require 'pp'

class BaseApp
  include CLI::ModularOptions
  extend CLI::WithOptions
  
  def initialize( args = {} )
    parse_options! args[:argv] unless args[:argv].nil?
  end

  cli_options do |p, cfg|
    cfg[:parser] = p
    puts 'configured'
  end
end

module FeatureOne
  extend CLI::WithOptions
  
  cli_options do |p, cfg|
    p.separator "\n  FeatureOne Options:"
    cfg[:one] ||= false
    p.on '--one' do |v|
      cfg[:one] = true
    end
  end
end

module FeatureTwo
  extend CLI::WithOptions
  
  cli_options do |p, cfg|
    p.separator "\n  FeatureTwo Options:"
    cfg[:two] ||= false
    p.on '--two' do |v|
      cfg[:two] = true
    end
  end

  cli_options do |p, cfg|
    cfg[:two_again] ||= false
    p.on '--two-again' do |v|
      cfg[:two_again] = true
    end
  end
end

class App1 < BaseApp
  include FeatureOne
  extend CLI::WithOptions
  
  def initialize( args = {} )
    super
    parser = cli_opts.delete :parser
    puts 'Help text:'
    puts parser.help
    puts ''
    puts 'cli_opts:'
    pp cli_opts
  end
  
  cli_options do |p, cfg|
    p.banner = "Banner: App"
    p.separator "\n  App1 Options:"
    cfg[:app] ||= false
    p.on '--app' do |v|
      cfg[:app] = true
    end
  end
end

class App2 < App1
  include FeatureTwo
  extend CLI::WithOptions
  
  cli_options do |p, cfg|
    p.banner = "Banner: App2"
  end
end

App2.new argv: ARGV
