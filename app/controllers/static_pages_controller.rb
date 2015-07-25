class StaticPagesController < ApplicationController
  def index
    @instances = Instance.order('name')
  end

  def sysadmin
  end
end
