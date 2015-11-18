require 'spec_helper'

describe Views::AbstractController::Rendering do
	context "enable this module" do
		before do
			Views::AbstractController::Rendering.enable
		end

		it "should do render" do
			a = Views::Render.new 'users'
			a.controller.render :show
		end
	end
end