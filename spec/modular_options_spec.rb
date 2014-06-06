require 'cli/modular_options'

describe CLI::WithOptions do
  let(:mod){ TestModels.new_module 'meh', false }
  
  it "doesn't create CLI_OPTS_HOOKS until necessary" do
    expect(mod.const_defined? :CLI_OPTS_HOOKS).to eq false
  end

  it 'requires a block to be given with cli_options' do
    expect{ mod.cli_options }.to raise_error ArgumentError
  end

  it 'adds hooks to modules' do
    mod.cli_options do; end
    expect(mod::CLI_OPTS_HOOKS).to be_an Array
  end
  
  it 'adds more hooks to modules' do
    5.times{ mod.cli_options do; end }
    expect(mod::CLI_OPTS_HOOKS.size).to be 5
  end
end

describe CLI::ModularOptions do
  let(:basic){ TestModels.new_class modular_options: true } 
  it 'has no hooks by default' do
    expect(basic.cli_hooks).to be_an(Array).and be_empty
  end
  
  context 'when included module has options' do
    let(:klass){ 
      TestModels.new_class(
        :modular_options => true, 
        :feature_modules => ['One', 'Two', 'Three']
      )
    }
    
    it 'inherits included cli_hooks' do
      expect(klass.cli_hooks.size).to be 3
    end
    
    it 'invokes hooks by the order in which they were included' do
      expect(klass.new([]).cli_opts[:order]).to eq ['One', 'Two', 'Three']
    end
  end

#  context 'when superclass has options' do
#  end
#  
#  context 'when module included by superclass has options' do
#  end
#
#  context 'when a class and its included modules have options' do
#  end
end

