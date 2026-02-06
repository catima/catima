class MessageDismissalsController < ApplicationController
  def create
    session[:dismissed_messages] ||= []
    session[:dismissed_messages] << params[:id].to_i
    session[:dismissed_messages].uniq!

    head :ok
  end
end
