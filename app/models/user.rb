class User < ActiveRecord::Base
  after_save do
    self.name = 'new name'
  end
end
