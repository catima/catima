class Admin::BaseController < ApplicationController
  layout "admin"
  skip_before_action :set_locale
  before_action :authenticate_user!
  after_action :verify_authorized

  private

  def default_url_options
    {}
  end
end
