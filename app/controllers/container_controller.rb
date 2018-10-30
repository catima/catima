# frozen_string_literal: true

class ContainerController < ApplicationController
  before_action :find_container

  def contact
    p container_params['body']
    email = @container.content['receiving_email']
    ContactMailer.send_message(container_params, email).deliver_later
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
