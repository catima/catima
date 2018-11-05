# frozen_string_literal: true

class ContainerController < ApplicationController
  before_action :find_container

  def contact
    unless verify_recaptcha
      return redirect_back fallback_location: root_path,
                           :alert => t('containers.contact.invalid_captcha')
    end

    receiver = @container.content['receiving_email']

    ContactMailer.send_request(
      receiver,
      container_params.to_h,
      @container.page.title,
      request.referer
    ).deliver_now

    redirect_back fallback_location: root_path, :notice => t('containers.contact.request_sent')
  end

  private

  def find_container
    @container = Container.find_by(:id => params[:container_id])
  end

  def container_params
    permitted_fields = %i(utf8 authenticity_token container_id commit locale)
    @container.content.each do |field, enabled|
      permitted_fields << field.to_sym if enabled
    end

    params.permit(permitted_fields)
  end
end
