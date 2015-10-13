class Admin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  after_action :verify_authorized
end
