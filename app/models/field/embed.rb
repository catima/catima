require 'uri'

class Field::Embed < ::Field
  store_accessor :options, :format
  store_accessor :options, :width
  store_accessor :options, :height
  store_accessor :options, :domains
  after_save :remove_width_height_value, :if => :code?

  FORMATS = %w(url code).freeze

  def item_link
    "/#{@item.catalog.slug}/#{I18n.locale}/#{@item.item_type.slug}/#{@item.id}"
  end

  def sql_type
    "VARCHAR(512)"
  end

  def url?
    options && options['format'] && options['format'] == 'url'
  end

  def code?
    options && options['format'] && options['format'] == 'code'
  end

  def width
    options['width']
  end

  def height
    options['height']
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
    update(:options => options.except("width", "height")) if (options["widht"] || options["height"])
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
      domain_values = record.fields.find_by(uuid: attrib).parsed_domains.map { |domains| domains["value"] }
      return if all_urls_valid?(value, domain_values)

      record.errors.add(
        attrib,
        "urls does not appear to a match the list of valid domains (#{domain_values.to_sentence})"
      )
    end

    private

    def is_wildcard_domain?(domain)
      domain.start_with?('*.')
    end

    def all_urls_valid?(value, domains)
      urls = URI.extract(value, ['http', 'https'])
      urls.map! { |url| get_host_without_www(url) }

      domains.each do |domain|
        if is_wildcard_domain?(domain)
          urls.map! { |url| url.include?(domain[2..-1]) ? remove_subdomain(url) : url }
        end
      end

      urls.map! { |url| ([url] & domains.map { |d| is_wildcard_domain?(d) ? d[2..-1] : d }).any? }.all?
    end

    def remove_subdomain(url)
      url.split('.').last(2).join('.')
    end

    def get_host_without_www(url)
      uri = URI.parse(url)
      uri = URI.parse("http://#{url}") if uri.scheme.nil?
      host = uri.host.downcase
      host.start_with?('www.') ? host[4..-1] : host
    end
  end
end
