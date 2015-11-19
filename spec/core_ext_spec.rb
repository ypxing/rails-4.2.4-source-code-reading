require 'spec_helper'

describe 'extension to Module' do
  context 'remove_existing_instance_methods' do
    before do
      @target = Module.new do
        def m; end
        protected def protected_m; end
        private def private_m; end
      end

      @template = Module.new do
        protected def protected_m; end
      end
    end

    it "can remove all methods from itself" do
      @target.remove_existing_instance_methods(@target)

      expect(@target.public_instance_methods(false)).to be_blank
      expect(@target.protected_instance_methods(false)).to be_blank
      expect(@target.private_instance_methods(false)).to be_blank
    end

    it "can remove methods according to template" do
      @target.remove_existing_instance_methods(@template)

      expect(@target.public_instance_methods(false)).to eq([:m])
      expect(@target.protected_instance_methods(false)).to be_blank
      expect(@target.private_instance_methods(false)).to eq([:private_m])
    end
  end

  context "copy_existing_instance_methods" do
    before do
      @target = Class.new do
        def m1; 'target' end
      end

      @source = Module.new do
        def m1; 'source' end
        def m2; end
        protected def protected_m; end
        private def private_m; end
      end

      @template = Module.new do
        def m1; 'template' end
      end
    end

    let(:target_obj) { @target.new }

    it "can copy all methods from one module" do
      @target.copy_existing_instance_methods(@source)

      expect(target_obj.m1).to eq('source')
      expect(target_obj).to respond_to(:m2)
      expect(@target.protected_instance_methods(false)).to include(:protected_m)
      expect(@target.private_instance_methods(false)).to include(:private_m)
    end

    it "can just copy methods from one module according to template" do
      @target.copy_existing_instance_methods(@source, @template)

      expect(target_obj.m1).to eq('source')
      expect(target_obj).not_to respond_to(:m2)
    end
  end

  context "remove_instance_methods_from_ancestors" do
    before do
      FakeModule1 = Module.new do
        def m; end
        def self.name; 'FakeModule'; end
      end

      FakeModule2 = Module.new do
        def m; end
        def self.name; 'FakeModule'; end
      end

      class FakeClass
        include FakeModule1
        include FakeModule2
      end

    end

    it "can remove methods from modules with specific name" do
      expect(FakeClass.new).to respond_to(:m)
      FakeClass.remove_instance_methods_from_ancestors('FakeModule')
      expect(FakeClass.new).not_to respond_to(:m)
    end
  end

  context "prefix_existing_instance_methods" do
    before do
      @target = Class.new do
        def m; end
        protected def protected_m; end
        private def private_m; end
      end

      @template = Module.new do
        protected def protected_m; end
      end
    end

    it "can add/remove prefix to all instance_methods of one class" do
      @target.prefix_existing_instance_methods('fake_')
      expect(@target.public_instance_methods(false)).to contain_exactly(:fake_m)
      expect(@target.protected_instance_methods(false)).to contain_exactly(:fake_protected_m)
      expect(@target.private_instance_methods(false)).to contain_exactly(:fake_private_m)

      @target.prefix_existing_instance_methods('fake_', @target, true)
      expect(@target.public_instance_methods(false)).to contain_exactly(:m)
      expect(@target.protected_instance_methods(false)).to contain_exactly(:protected_m)
      expect(@target.private_instance_methods(false)).to contain_exactly(:private_m)
    end

    it "can add/remove prefix to all instance_methods of one class" do
      @target.prefix_existing_instance_methods('fake_', @template)
      expect(@target.public_instance_methods(false)).to contain_exactly(:m)
      expect(@target.protected_instance_methods(false)).to contain_exactly(:fake_protected_m)
      expect(@target.private_instance_methods(false)).to contain_exactly(:private_m)

      @target.prefix_existing_instance_methods('fake_', @template, true)
      expect(@target.public_instance_methods(false)).to contain_exactly(:m)
      expect(@target.protected_instance_methods(false)).to contain_exactly(:protected_m)
      expect(@target.private_instance_methods(false)).to contain_exactly(:private_m)
    end
  end

end
