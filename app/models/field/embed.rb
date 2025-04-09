require 'uri'

class Field::Embed < Field
  store_accessor :options, :format
  store_accessor :options, :width
  store_accessor :options, :height
  store_accessor :options, :domains
  after_save :remove_width_height_value, if: :iframe?

  FORMATS = %w(url iframe).freeze
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
    "TEXT"
  end

  def url?
    format == 'url'
  end

  def iframe?
    format == 'iframe'
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

      if record.fields.find_by(uuid: attrib).parsed_domains.empty?
        record.errors.add(attrib, I18n.t("errors.messages.no_domains"))
        return false
      end

      field = record.fields.find_by(uuid: attrib)
      domains = field.parsed_domains.pluck("value")
      if field.iframe?
        validate_iframe(value, record, attrib, domains)
      else
        validate_url(value, record, attrib, domains)
      end
    end

    private

    def validate_url(url, record, attrib, domains)
      unless a_valid_url?(url)
        record.errors.add(attrib, I18n.t("errors.messages.invalid_url"))
        return false
      end

      unless url.starts_with?('http')
        record.errors.add(attrib, I18n.t("errors.messages.invalid_url"))
        return false
      end

      unless domains_include_url?(url, domains)
        record.errors.add(attrib, I18n.t("errors.messages.invalid_domain", domains: domains.to_sentence))
        return false
      end

      true
    end

    def a_valid_url?(url)
      uri = URI.parse(url)
      uri.host.present?
    rescue URI::InvalidURIError
      false
    end

    def add_should_have_one_iframe_error(record, attrib)
      record.errors.add(
        attrib,
        I18n.t("errors.messages.should_have_one_iframe")
      )
    end

    def validate_iframe(value, record, attrib, domain)
      html_doc = Nokogiri::HTML(value)
      iframe_nodes = html_doc.search('iframe')
      if iframe_nodes.empty?
        add_should_have_one_iframe_error(record, attrib)
        return
      end
      record.data[attrib] = iframe_nodes.map(&:to_s).join
      iframe_nodes
        .map { |node| node.attr('src') }.compact
        .each { |url| validate_url(url, record, attrib, domain) }
    end

    def domains_include_url?(url, domains)
      parsed_url = split_url(get_host_without_www(url))
      parsed_domains = domains.map { |domain| replace_wildcard_with_regex(split_url(domain)) }
      parsed_domains.any? { |domain| parsed_url_is_valid_for_domain?(parsed_url, domain) }
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

    def parsed_url_is_valid_for_domain?(parsed_url, domain)
      parsed_url.each_with_index.all? do |u_item, i|
        case domain[i]
        when ".*"
          true
        when "www"
          u_item == ""
        else
          u_item == domain[i]
        end
      end
    end
  end
end
