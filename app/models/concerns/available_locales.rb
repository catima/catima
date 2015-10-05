module AvailableLocales
  private

  def available_locales
    I18n.available_locales.map(&:to_s)
  end
end
