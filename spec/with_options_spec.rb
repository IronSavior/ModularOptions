require 'cli/modular_options'
require 'helpers/test_model'

describe CLI::WithOptions do
  let(:mod){ TestModel.new_module :add_options => false }
  
  it "Doesn't create @cli_options_hooks until necessary" do
    expect(mod.instance_variable_defined? :@cli_options_hooks).to eq false
  end

  it 'Requires a block to be given with cli_options' do
    expect{ mod.cli_options }.to raise_error ArgumentError
  end

  it 'Adds hooks to modules' do
    mod.cli_options do; end
    expect(mod.instance_variable_get :@cli_options_hooks).to be_an Array
  end
  
  it 'Adds more hooks to modules' do
    5.times{ mod.cli_options do; end }
    expect(mod.instance_variable_get(:@cli_options_hooks).size).to be 5
  end
end
