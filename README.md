Modular CLI Options
===================

Facilitates modular application design by allowing you to declare command-line
options in the context of a class or module and consume them in the context of
an object instance using conventional ruby inheritance semantics.

### Install:

    gem install cli-modular_options

### Example:
```ruby
require 'cli/modular_options'

module DatabaseStuff
  extend CLI::WithOptions
  
  # Your mixin methods might go here
  
  cli_options do |parser|
    p.separator 'Database Options:'
    p.on '--db-user', 'Database username' do |v|
      cli_opts[:db_user] = v
    end
    p.on '--db-pass', 'Database password' do |v|
      cli_opts[:db_pass] = v
    end
  end
end

module StandardOptions
  extend CLI::WithOptions
  cli_options do |parser|
    p.on_head '-h', '--help', 'Display help' do
      cli_opts[:show_help] = true
      cli_opts[:parser] = parser
    end
  end
end

class MyApp
  include CLI::ModularOptions
  include DatabaseStuff
  include StandardOptions
  
  def show_help
    puts cli_opts[:parser]
    Process.exit 0
  end
  
  def initialize( argv = ARGV.map(&:dup) )
    parse_options! argv
    # Your options are available in cli_opts
    show_help if cli_opts[:show_help]
  end
end

# You can inherit options in a subclass
class MyDerivedApp < MyApp
  # Maybe you prefer to let the caller decide what to do about --help
  def show_help
    throw :help, cli_opts[:parser]
  end
end

# You can append more options directly to a class
class MyVerboseApp < MyApp
  extend CLI::WithOptions
  cli_options do |parser|
    parser.separator 'Options added by MyVerboseApp:'
    cli_opts[:verbose] = false
    parser.on '--verbose', 'Enable verbose output' do
      cli_opts[:verbose] = true
    end
  end
end

# The order in which callbacks are invoked is well-defined.
# Your cli_options blocks are called in a natural order that aligns
# with normal ruby inheritance semantics.
class MyQuietApp < MyVerboseApp
  cli_options do |parser|
    # This appears on the list of options after those declared in MyVerboseApp
    parser.on '--no-verbose', 'Disable verbose output' do
      cli_opts[:verbose] = false
    end
  end
end
```

### Copyrights
Copyright (C) 2014 Erik Elmore <erik@erikelmore.com>

### License
MIT License.  See LICENSE file for full text.
