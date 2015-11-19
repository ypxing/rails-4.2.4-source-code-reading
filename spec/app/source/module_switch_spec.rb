require 'spec_helper'

describe ModuleSwitch do
  before do
    module FakeModule
      def target
        'fake_module'
      end
    end

    class FakeClass
      include FakeModule
      def target
        'fake_class'
      end
    end

    module Mine
      module FakeClass
        extend ModuleSwitch
        def target
          "mine with #{super}"
        end
      end
    end

    @obj = FakeClass.new
  end

  it "can enable/disable shim module" do
    Mine::FakeClass.enable
    expect(@obj.target).to eq('mine with fake_module')

    Mine::FakeClass.disable
    expect(@obj.target).to eq('fake_class')

    Mine::FakeClass.enable(false)
    expect(@obj.target).to eq('mine with fake_class')

    # must disable this so that other cases will not be impacted
    Mine::FakeClass.disable
  end

  it "can insert shim module without any method" do
    Mine::FakeClass.insert
    expect(@obj.target).to eq('fake_class')
    expect(FakeClass.ancestors).to include(Mine::FakeClass::SHIM)
  end

  it "can create shim module without any method" do
    expect(Mine::FakeClass.shim_const).to be Mine::FakeClass::SHIM
  end

  it "has target_const" do
    expect(Mine::FakeClass.target_const).to be(FakeClass)
  end
end