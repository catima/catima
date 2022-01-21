class SuggestionsController < ApplicationController
  include ControlsCatalog
  include ControlsItemList

  before_action :find_item_type
  before_action :ensure_valid_captcha
  before_action :allow_anonymous_suggestion
  before_action :find_item

  def create
    suggestion = @item.suggestions.new(suggestion_params.merge(item_type_id: @item.item_type_id, catalog_id: @item.catalog_id, user_id: current_user&.id))
    if suggestion.save
      SuggestionsMailer.send_request(@item_type.suggestion_email, suggestion).deliver_now
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".error", errors: suggestion.errors.full_messages.to_sentence)
    end
    redirect_back fallback_location: item_path(id: @item.id)
  end

  private

  def suggestion_params
    params.require(:suggestion).permit(:content)
  end

  def find_item_type
    @item_type = catalog.item_types.find_by!(slug: params[:item_type_slug])
  end

  def find_item
    @item = @item_type.public_items.find(params[:item_id]).behaving_as_type
  end

  def ensure_valid_captcha
    return if verify_recaptcha
    redirect_back fallback_location: root_path, flash: {alert: t('containers.contact.invalid_captcha')}
  end

  def allow_anonymous_suggestion
    return if current_user || @item_type.allow_anonymous_suggestions?
    head :unauthorized
  end
end
