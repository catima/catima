class SuggestionsController < ApplicationController
  include ControlsCatalog
  include ControlsItemList

  before_action :find_item_type
  before_action :find_item, only: [:create, :destroy, :update_processed]
  before_action :find_suggestion, only: [:destroy, :update_processed]

  def create
    return if suggestion_params[:content].blank?

    unless verify_recaptcha
      return redirect_back fallback_location: root_path,
                           :alert => t('containers.contact.invalid_captcha')
    end

    return if item_type.allow_anonymous_suggestions? && !current_user


    if (suggestion = @item.suggestions.create(suggestion_params.merge(item_type_id: @item.item_type_id, catalog_id: @item.catalog_id, user_id: current_user.authenticated? ? current_user.id : nil)))
      receiver = @item_type.suggestion_email

      SuggestionsMailer.send_request(
        receiver,
        suggestion
      ).deliver_now
    end
    redirect_to item_path(id: @item.id)
  end

  def destroy
    @suggestion.delete
    redirect_to edit_catalog_admin_item_path(id: @item.id)
  end

  def update_processed
    @suggestion.process
    redirect_to edit_catalog_admin_item_path(id: @item.id)
  end

  private

  def suggestion_params
    params.require(:suggestion).permit(:content)
  end

  attr_reader :item_type

  helper_method :item_type

  def find_item_type
    @item_type =
      catalog.item_types.where(:slug => params[:item_type_slug]).first!
  end

  def find_item
    @item = item_type.public_items.find(params[:item_id]).behaving_as_type
  end

  def find_suggestion
    @suggestion = @item.suggestions.find(params[:id])
  end
end
