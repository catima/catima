class ViatimagesItemsController < ItemsController
  include FieldsHelper
  include AdvancedSearchConfig

  def index
    super

    # Check if images are requested for a single domain
    if params['domaine']
      lang_domain = params['domaine']
      @domain = lang_domain[3..]
    end

    # If corpus id request parameter is available, send corresponding corpus item to view
    if params['corpus'].present?
      @corpus = Item.where(id: params['corpus']).first

      @corpus.applicable_fields.each do |field|
        @titre = field if field.slug == "titre"
        @titre_trad = field if field.slug == "titre-traduit"
        @titre_long = field if field.slug == "titre-long"
        @lieu_edition = field if field.slug == "lieu-edition"
        @editeur = field if field.slug == "editeur"
        @personne_associee = field if field.slug == "personne-associee"
        @siecle_edition = field if field.slug == "siecle-edition"
        @siecle_voyage = field if field.slug == "siecle-voyage"
        @date_edition_debut = field if field.slug == "date-edition-debut"
        @date_edition_fin = field if field.slug == "date-edition-fin"
        @format = field if field.slug == "format"
        @tome = field if field.slug == "tome"
        @nombre_illustrations = field if field.slug == "nombre-illustrations"
        @cote = field if field.slug == "cote"
        @url_catalogue = field if field.slug == "url-catalogue"
        @remarques = field if field.slug == "remarques"
        @texte_online = field if field.slug == "texte-online"
        @collection_ouvrage = field if field.slug == "collection-ouvrage"
        @langue_ouvrage = field if field.slug == "langue-ouvrage"
        @autres_editions = field if field.slug == "autres-editions"
        @provenance_collection = field if field.slug == "provenance"
        @description_collection = field if field.slug == "description"
      end

      if @date_edition_debut || @date_edition_fin
        date_edition_debut = field_value(@corpus, @date_edition_debut)
        date_edition_fin = field_value(@corpus, @date_edition_fin)
        @date_edition = if date_edition_debut == date_edition_fin
                          date_edition_debut
                        elsif date_edition_debut && date_edition_fin
                          "#{date_edition_debut}-#{date_edition_fin}"
                        else
                          date_edition_debut || date_edition_fin
                        end
      end

      @etablissement = @corpus.get_value('etablissement')

      fields_and_item_references(@corpus) do |_, browse|
        @images_count = browse.total_count if browse.item_type.slug === 'images'
      end
    end

    # Retrieve the default advanced search configuration
    # to show the advanced search link in the view
    search_conf_param
  end

  def show
    super

    return unless @item.present?
    # To show a corpus we rather show the list of images where the corpus
    # details are rendered at the top of the image list.
    return redirect_to items_path(item_type_slug: "images", corpus: @item.id) if @item_type.slug == "corpus"

    # Prepare some objects for showing the image list (item type "images")
    if @item_type.slug == "images"
      @item.applicable_fields.each do |field|
        @image_id = field if field.slug == "id-image"
        @image = field if field.slug == "image"
        @texte_dans_image = field if field.slug == "texte-dans-image"
        @titre_original = field if field.slug == "titre-original"
        @titre_trad = field if field.slug == "titre-traduit"
        @illustrateurs = field if field.slug == "personne-associee"
        @corpus = field if field.slug == "corpus"
        @description = field if field.slug == "description"
        @remarques = field if field.slug == "remarques"
        @image_lieu_edition = field if field.slug == "image-lieu-edition"
        @date_evenement = field if field.slug == "date-evenement"
        @illustration_composee = field if field.slug == "illustration-composee"
        @planche_depliante = field if field.slug == "planche-depliante"
        @en_couleur = field if field.slug == "en-couleurs"
        @largeur = field if field.slug == "original-width-mm"
        @hauteur = field if field.slug == "original-height-mm"
        @echelle_origine = field if field.slug == "echelle-origine"
        @emplacement = field if field.slug == "emplacement"
        @emplacement_ouvrage = field if field.slug == "emplacement-dans-ouvrage"
        @genre = field if field.slug == "genre"
        @descripteur_carte = field if field.slug == "descripteur-carte"
        @critere_technique = field if field.slug == "critere-technique"
        @location = field if field.slug == "geo-location"
        @domaine = field if field.slug == "domaine"
        @keyword = field if field.slug == "mot-cle"
        @geographie = field if field.slug == "geo"
        @texte_legende = field if field.slug == "texte-legende"
        @chercheur = field if field.slug == "chercheur"
        @texte_associe = field if field.slug == "texte-associe"
      end

      # define image thumbnail size
      @image_size = '400x400'

      # get local value for boolean true
      @yes = t('yes')

      if @geographie
        # regroup all geography values by feature-class
        @geographie_sorted = @item.get_value(@geographie).group_by { |item| item.item_type.find_field('geo-feature-class').raw_value(item) }.values
      end

      if @corpus
        # define edition date by formatting date-edition-debut and date-edition-fin
        date_debut = field_value(@item.get_value(@corpus), @item.get_value(@corpus).item_type.find_field('date-edition-debut'))
        date_fin = field_value(@item.get_value(@corpus), @item.get_value(@corpus).item_type.find_field('date-edition-fin'))
        @date_edition = if date_debut == date_fin
                          date_debut
                        elsif date_debut && date_fin
                          "#{date_debut}-#{date_fin}"
                        else
                          date_debut || date_fin
                        end
      end

      # Set the base path for the geo entities links
      @base_feature_path = "#{viatimages_pages_path(locale: I18n.locale, slug: 'geosearch')}?feature="
    end

    # Retrieve the default advanced search configuration
    # to show the advanced search link in the view
    search_conf_param
  end
end
