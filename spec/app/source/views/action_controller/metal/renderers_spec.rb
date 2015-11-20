require 'spec_helper'

describe Views::ActionController::Renderers do
  context "enable this module" do
    before do
      Views::ActionController::Renderers.enable_shim
    end

    it "should do render" do
      a = Views::Render.new 'users'
      a.controller.render :show
    end
  end
end