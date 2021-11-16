require 'uri'

class Field::Embed < ::Field
  store_accessor :options, :format
  store_accessor :options, :width
  store_accessor :options, :height
  store_accessor :options, :domains
  after_save :remove_width_height_value, if: :code?

  FORMATS = %w(url code).freeze
  DEFAULT_IFRAME_WIDTH = 900
  DEFAULT_IFRAME_HEIGHT = 400

  def item_link
    "/#{@item.catalog.slug}/#{I18n.locale}/#{@item.item_type.slug}/#{@item.id}"
  end

  def iframe_width
    width.present? ? width.to_i : DEFAULT_IFRAME_WIDTH
  end

  def iframe_height
    height.present? ? height.to_i : DEFAULT_IFRAME_HEIGHT
  end

  def sql_type
    "VARCHAR(512)"
  end

  def url?
    format == 'url'
  end

  def code?
    format == 'code'
  end

  def parsed_domains
    domains.present? ? JSON.parse(domains) : []
  end

  def human_readable?
    false
  end

  def allows_unique?
    false
  end

  def custom_field_permitted_attributes
    %i(format width height domains)
  end

  def remove_width_height_value
    update!(options: options.except("width", "height")) if width || height
  end

  def build_validators
    [EmbedValidator]
  end

  class EmbedValidator < ActiveModel::Validator
    include CatalogAdmin::EmbedHelper

    def validate(record)
      attrib = Array.wrap(options[:attributes]).first
      value = record.public_send(attrib)

      return if value.blank?
      return if record.fields.find_by(uuid: attrib).parsed_domains.none?

      field = record.fields.find_by(uuid: attrib)
      domains = field.parsed_domains.map { |d| d["value"] }
      validate_by_domains(value, record, attrib, field.url?, domains)
    end

    private

    def validate_by_domains(value, record, attrib, is_url, domains)
      begin
        if is_url
          uri = URI.parse(value)
          add_invalid_url_error(record, attrib) if uri.host.blank?
        end
      rescue URI::InvalidURIError
        add_invalid_url_error(record, attrib)
      ensure
        return true if all_urls_are_valid?(value, domains)

        record.errors.add(
          attrib,
          I18n.t("errors.messages.invalid_domain", domains: domains.to_sentence)
        )
        return false
      end
    end

    def add_invalid_url_error(record, attrib)
      record.errors.add(
        attrib,
        I18n.t("errors.messages.invalid_url")
      )
    end

    def all_urls_are_valid?(value, domains)
      urls = URI.extract(value, %w[http https])
      parsed_urls = urls.map { |url| split_url(get_host_without_www(url)) }
      parsed_urls.map! { |u| ["www#{u[0].blank? ? '' : '.'}#{u[0]}", u[1], u[2]] }
      parsed_domains = domains.map { |domain| replace_wildcard_with_regex(split_url(domain)) }
      parsed_urls.all? { |url| parsed_domains.any? { |domain| url_is_valid_for_domain?(url, domain) } }
    end

    def get_host_without_www(url)
      uri = URI.parse(url)
      uri = URI.parse("http://#{url}") if uri.scheme.nil?
      host = uri.host.downcase
      host.start_with?('www.') ? host[4..] : host
    end

    def split_url(url)
      case url.split('.').length
      when 1
        ['', url, '']
      when 2
        ['', url.split('.')].flatten
      when 3
        url.split('.')
      else
        ['', '', '']
      end
    end

    def replace_wildcard_with_regex(split_url)
      split_url.map { |d| d.gsub('*', '.*') }
    end

    def url_is_valid_for_domain?(url, domain)
      url.each_with_index.all? { |u_item, i| domain[i] == '.*' ? true : u_item == domain[i] }
    end
  end
end
