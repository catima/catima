class StaticPagesController < ApplicationController
  before_action :set_instances, only: [:index, :sysadmin]
  
  def index
  end

  def sysadmin
  end
  
  private
  
    def set_instances
      @instances = Instance.order('name')
    end
end
