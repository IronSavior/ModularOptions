require 'cli/modular_options'
require 'helpers/test_model'

describe CLI::ModularOptions do
  shared_examples_for TestModel do
    it 'Inherits included cli_hooks' do
      expect(klass.cli_hooks.size).to be call_order.size unless call_order.nil?
    end
    
    it 'Invokes cli_hooks in the correct order' do
      expect(klass.new.cli_opts[:call_order]).to eq call_order
    end
  end
  
  context 'When no options' do
    let(:klass){ TestModel.new_class modular_options: true }
    let(:call_order){ nil }
    it_behaves_like TestModel
  end
  
  context 'When included modules have options' do
    let(:klass){ TestModel.new_class(
      :modular_options => true, 
      :feature_modules => ['One', 'Two', 'Three']
    )}
    let(:call_order){ ['One', 'Two', 'Three'] }
    it_behaves_like TestModel
  end
  
  context 'When both a class and its included modules have options' do
    let(:klass){ TestModel.new_class(
      :name => 'Base',
      :modular_options => true,
      :with_options => true,
      :feature_modules => ['One', 'Two', 'Three']
    )}
    let(:call_order){ ['One', 'Two', 'Three', 'Base'] }
    it_behaves_like TestModel
  end

  context 'When base class has options' do
    let(:klass){ TestModel.new_class(
      :name => 'Sub',
      :base => TestModel.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true
      )
    )}
    let(:call_order){ ['Base'] }
    it_behaves_like TestModel
  end
  
  context 'when base class includes modules with options' do
    let(:klass){ TestModel.new_class(
      :base => TestModel.new_class(
        :modular_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
    )}
    let(:call_order){ ['One', 'Two', 'Three'] }
    it_behaves_like TestModel
  end
  
  context 'When base class both has and includes options' do
    let(:klass){ TestModel.new_class(
      :name => 'Derived',
      :base => TestModel.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
    )}
    let(:call_order){ ['One', 'Two', 'Three', 'Base'] }
    it_behaves_like TestModel
  end
  
  context 'When both base class and derived class have and include options' do
    let(:klass){ TestModel.new_class(
      :name => 'Derived',
      :with_options => true,
      :feature_modules => ['Four', 'Five', 'Six'],
      :base => TestModel.new_class(
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
    it_behaves_like TestModel
  end
  
  context 'When re-opening base class to include module with options' do
    let(:klass){
      base = TestModel.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
      sub = TestModel.new_class(
        :name => 'Sub',
        :with_options => true,
        :feature_modules => ['Four', 'Five', 'Six'],
        :base => base
      )
      base.send :include, TestModel.new_module(:name => 'Added')
      sub
    }
    let(:call_order){ Array[
      'One', 'Two', 'Three', 'Added', 'Base',
      'Four', 'Five', 'Six', 'Sub'
    ]}
    it_behaves_like TestModel
  end
  
  context 'When re-opening base class to declare options directly' do
    let(:klass){
      base = TestModel.new_class(
        :name => 'Base',
        :modular_options => true,
        :with_options => true,
        :feature_modules => ['One', 'Two', 'Three']
      )
      sub = TestModel.new_class(
        :name => 'Sub',
        :with_options => true,
        :feature_modules => ['Four', 'Five', 'Six'],
        :base => base
      )
      TestModel.new_cli_hook base, 'BaseAgain'
      sub
    }
    let(:call_order){ Array[
      'One', 'Two', 'Three', 'Base', 'BaseAgain',
      'Four', 'Five', 'Six', 'Sub'
    ]}
    it_behaves_like TestModel
  end
end
