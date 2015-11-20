require 'spec_helper'

describe Views::ActionController::Rendering do
  context "enable this module" do
    before do
      Views::ActionController::Rendering.enable_shim
    end

    it "should do render" do
      a = Views::Render.new 'users'
      a.controller.render :show
    end
  end
end