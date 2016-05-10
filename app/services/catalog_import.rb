class CatalogImport
  
  def initialize
  end
  
  def import(jsonfile)
    puts "importing catalog from '#{jsonfile}..."
    f = File.open(jsonfile)
    i = JSON.parse(f.read)
    f.close
    if i['type'] == 'viim-catalog'
      import_structure(i)
    elsif i['type'] == 'viim-data'
      import_data(i)
    else
      raise "ERROR. '#{jsonfile}' is not a valid catalog dump."
    end
  end


  def import_structure(i)
    if !i['slug']
      raise "ERROR. '#{jsonfile}' is not a valid catalog dump."
    end
    existing_catalog = Catalog.find_by({slug: i['slug']})
    if !existing_catalog.nil?
      raise "ERROR. Catalog '#{i['slug']}' already exists. Aborting."
    end

    c = create_catalog(i)
    create_choice_sets(c, i['structure']['choice_sets'])
    create_item_types(c, i['structure']['item_types'], i['structure']['choice_sets'])
  end


  def import_data(i)
    if !i['catalog']
      raise "ERROR. '#{jsonfile}' is not a valid catalog dump."
    end
    catalog = Catalog.find_by({slug: i['catalog']})
    if catalog.nil?
      raise "ERROR. Catalog '#{i['slug']}' does not exist. Aborting."
    end

    load_item_types(catalog, i['item_types'])
  end


  private

  def create_catalog(i)
    c = Catalog.new({
      name: i['name'],
      other_languages: i['other_languages'],
      primary_language: i['primary_language'],
      requires_review: i['requires_review'],
      slug: i['slug']
    })
    c.save
    c
  end

  def create_choice_sets(catalog, json_choice_sets)
    json_choice_sets.each do |i|
      cs = catalog.choice_sets.build({
        name: i['name'][catalog.primary_language],
        slug: i['slug']
      })
      cs.save

      i['choices'].each do |choice|
        ch = cs.choices.build({
          short_name_translations: {
            short_name_fr: choice['name']['fr'],
            short_name_de: choice['name']['de'],
            short_name_en: choice['name']['en'],
            short_name_it: choice['name']['it']
          },
          long_name_translations: {
            long_name_fr: (choice['long_name'] || {'fr':nil})['fr'],
            long_name_de: (choice['long_name'] || {'de':nil})['de'],
            long_name_en: (choice['long_name'] || {'en':nil})['en'],
            long_name_it: (choice['long_name'] || {'it':nil})['it']
          },
        })
        ch.save
      end
    end

  end

  def create_item_types(catalog, item_types, choice_sets)
    item_types.each do |i|
      it = catalog.item_types.build({
        slug: i['slug'],
        name_translations: {
          name_fr: i['name']['fr'],
          name_de: i['name']['de'],
          name_en: i['name']['en'],
          name_it: i['name']['it']
        },
        name_plural_translations: {
          name_plural_fr: i['name_plural']['fr'],
          name_plural_de: i['name_plural']['de'],
          name_plural_en: i['name_plural']['en'],
          name_plural_it: i['name_plural']['it']
        }
      })
      it.save

      i['fields'].each do |f|
        fld = it.fields.build({
          type: Field::TYPES[f['type']],
          slug: f['slug'],
          name_translations: {
            name_fr: f['name']['fr'],
            name_de: f['name']['de'],
            name_en: f['name']['en'],
            name_it: f['name']['it']
          },
          name_plural_translations: {
            name_plural_fr: f['name_plural']['fr'],
            name_plural_de: f['name_plural']['de'],
            name_plural_en: f['name_plural']['en'],
            name_plural_it: f['name_plural']['it']
          },
          field_set_type: 'ItemType',
          comment: f['comment'],
          default_value: f['default_value'],
          display_in_list: f['display_in_list'] || false,
          i18n: f['i18n'] || false,
          multiple: f['multiple'] || false,
          ordered: f['ordered'] || false,
          primary: f['primary'] || false,
          required: f['required'] || false,
          unique: f['unique'] || false
        })

        if f['choice_set']
          cs = catalog.choice_sets.find_by({slug: f['choice_set']})
          fld.choice_set_id = cs.id
        end

        if f['reference']
          ref = catalog.item_types.first
          fld.related_item_type_id = ref.id
        end

        fld.save
      end
    end
  end



  def load_item_types(catalog, item_types)
    item_types.each do |item_type_json|
      item_type = catalog.item_types.find_by({slug: item_type_json['item_type']})
      puts "   loading item type #{item_type.slug}..."
      item_type_json['items'].each do |item_json|
        load_item(item_type, item_json)
      end
    end
  end


  def load_item(item_type, item_json)
    item = item_type.items.new.tap do |item|
      item.catalog = item_type.catalog
      item.creator = User.first
    end.behaving_as_type
    d = {}
    item_json.each do |k,v|
      f = item.fields.find_by({slug:k})
      puts "   Warning: field #{k} not found" if f.nil?
      d.merge!(f.prepare_value(v)) unless f.nil?
    end
    item.update(d)
    ok = item.save({validate:false})
    puts "   Warning: item #{item_json} could not be imported" if !ok
  end

end