require 'cli/modular_options'

describe CLI::WithOptions do
  let(:mod){ TestModels.new_module :add_options => false }
  
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
  shared_examples_for TestModels do
    it 'Inherits included cli_hooks' do
      expect(klass.cli_hooks.size).to be call_order.size unless call_order.nil?
    end
    
    it 'Invokes cli_hooks in the correct order' do
      expect(klass.new([]).cli_opts[:call_order]).to eq call_order
    end
  end
  
  context 'When no options' do
    let(:klass){ TestModels.new_class modular_options: true }
    let(:call_order){ nil }
    it_behaves_like TestModels
  end
  
  context 'When included modules have options' do
    let(:klass){ TestModels.new_class(
      :modular_options => true, 
      :feature_modules => ['One', 'Two', 'Three']
    )}
    let(:call_order){ ['One', 'Two', 'Three'] }
    it_behaves_like TestModels
  end
  
  context 'When both a class and its included modules have options' do
    let(:klass){ TestModels.new_class(
      :name => 'Base',
      :modular_options => true,
      :with_options => true,
      :feature_modules => ['One', 'Two', 'Three']
    )}
    let(:call_order){ ['One', 'Two', 'Three', 'Base'] }
    it_behaves_like TestModels
  end

  context 'When base class has options' do
    let(:klass){ TestModels.new_class(
      :name => 'Sub',
      :base => TestModels.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true
      )
    )}
    let(:call_order){ ['Base'] }
    it_behaves_like TestModels
  end
  
  context 'when base class includes modules with options' do
    let(:klass){ TestModels.new_class(
      :base => TestModels.new_class(
        :modular_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
    )}
    let(:call_order){ ['One', 'Two', 'Three'] }
    it_behaves_like TestModels
  end
  
  context 'When base class both has and includes options' do
    let(:klass){ TestModels.new_class(
      :name => 'Derived',
      :base => TestModels.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
    )}
    let(:call_order){ ['One', 'Two', 'Three', 'Base'] }
    it_behaves_like TestModels
  end
  
  context 'When both base class and derived class have and include options' do
    let(:klass){ TestModels.new_class(
      :name => 'Derived',
      :with_options => true,
      :feature_modules => ['Four', 'Five', 'Six'],
      :base => TestModels.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
    )}
    let(:call_order){ Array[
      'One', 'Two', 'Three', 'Base',
      'Four', 'Five', 'Six', 'Derived'
    ]}
    it_behaves_like TestModels
  end
  
  context 'When re-opening base class to include module with options' do
    let(:klass){
      base = TestModels.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
      sub = TestModels.new_class(
        :name => 'Sub',
        :with_options => true,
        :feature_modules => ['Four', 'Five', 'Six'],
        :base => base
      )
      base.send :include, TestModels.new_module(:name => 'Added')
      sub
    }
    let(:call_order){ Array[
      'One', 'Two', 'Three', 'Added', 'Base',
      'Four', 'Five', 'Six', 'Sub'
    ]}
    it_behaves_like TestModels
  end
  
  context 'When re-opening base class to declare options directly' do
    let(:klass){
      base = TestModels.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
      sub = TestModels.new_class(
        :name => 'Sub',
        :with_options => true,
        :feature_modules => ['Four', 'Five', 'Six'],
        :base => base
      )
      TestModels.new_test_hook base, 'BaseAgain'
      sub
    }
    let(:call_order){ Array[
      'One', 'Two', 'Three', 'Base', 'BaseAgain',
      'Four', 'Five', 'Six', 'Sub'
    ]}
    it_behaves_like TestModels
  end
end

