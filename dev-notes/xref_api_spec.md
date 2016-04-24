# Xref field API specification

`Xref` is one of the field types of CATIMA. It allows for including external data inside a catalog. The **xref service** is a remote server with a specific JSON API giving read-only access to the possible data values to be stored in a `xref` field. This section describes how the JSON API of a **xref service** must be formatted in order to be valid.

Every **xref service** has the same structure:

- A *namespace* which allows the **xref service** to serve different variants of the data for different catalogs.
- A *collection of items*, e.g. keywords. Each item has the following properties:
	- a unique `id`
	- a `name` in one or several languages
	- one or several `category` where the item belongs to
	- optionally other properties specific to the collection (and which are ignored by the xref field).

The complete set of properties for a collection of items is described by the `GET /` ressource.

The service API is specific to the namespace. The base URL of the API is `https://<server>/<service>/<namespace>/api/v1/`, which is also the `GET / ` resource.

The available resources are now described in detail.

## GET /

Complete example URL: 
`https://vss.naxio.ch/keywords/viatimages/api/v1/`

Returns the name, description and localization information on the service. An example result would be:

	{
		"locales": ["en", "fr", "de"],
		"item_name": {
			"en": "keyword",
			"fr": "mot-clé",
			"de": "Schlagwort"
		},
		"item_name_plural": {
			"en": "keywords",
			"fr": "mot-clés",
			"de": "Schlagwörter"
		},
		"fields": [
			{
				"slug": "name",
				"field_name": {
					"en": "name",
					"fr": "nom",
					"de": "Name"
				}
			}, {
				"slug": "name_extended",
				"field_name": {
					"en": "extended name",
					"fr": "nom étendu",
					"de": "erweiterter Name"
				}
			}, {
				"slug": "category",
				"field_name": {
					"en": "category",
					"fr": "catégorie",
					"de": "Kategorie"
				}
			}
		]
	}

The fields `name` and `category` are mandatory parts of a xref service. The `slug` is the field identifier. Additionally to these fields, items also have a unique `id`. Consequently, `id` can not be used as a field slug.

The **locale** of the response can be defined using the `locale` parameter which takes one or several languages (e.g. `locale=en` or `locale=en,de`). By default, all available locales are returned.


## GET items

Represents the service items, such as the keywords. It returns a paginated list of the items. 

Results are paginated using an `offset` and a `limit` parameter.
Default page size is 100 items. A possible response:

	{
		"count": 4578,
		"offset": 0,
		"limit": 100,
		"next": "https://vss.naxio.ch/keywords/viatimages/api/v1/items?limit=100&offset=100",
		"previous": null,
		"results": [
			{
				"id": 1,
				"name": {"en": "tree", "fr": "arbre", "de": "Baum"},
				"name-extended": null,
				"category": {
					"id": 1, "name": {"en": "biology", "fr": "biologie", "de": "Biologie"}
				}
			},
			{
				"id": 2,
				"name": {"en": "landscape", "fr": "paysage", "de": "Landschaft"},
				"name-extended": null,
				"category": {
					"id": 2, "name": {"en": "geography", "fr": "géographie", "de": "Geographie"}
				}
			}
		]
	}

**Definition of the locale of the response** can be done using the `locale` parameter. For example, `locale=fr` returns a response exclusively in French. It is possible to specify more than one locale, e.g. `locale=fr,en` for French and English.

**Selection of the fields to return** can be done using the `fields` parameter, e.g. `fields=name,name_extended` only returns these two fields. `id` is always returned.

**Ordering of the result** can be defined using the `sort` parameter which takes the list of fields to sort, e.g. `sort=category,name` returns the items sorted by category first and by name. Descendant sorting can be done using the `desc` parameter. E.g. `sort=category,name&desc=name` orders the result by category first and then by name in reverse order. In case where the result set has more than one locale, the locale of the sorting can be defined along with the field name, e.g. `sort=category:fr`.

**Filtering** is possible using the field slug as parameter and providing the desired value(s). Multiple values are comma-separated. E.g. getting the items of one category can be done with `category=biology`. Filtering is done in the current locale. The placeholder `*` can be used for simple searching, e.g. `category=bio*` returns all items where the category starts with *bio*.

In this way, it is possible to retrieve the items given a list of IDs, e.g. `GET items?id=1,5,7,10`.


## GET items/:id

Returns a single item, such as:

	{
		"id": 2,
		"name": {"en": "landscape", "fr": "paysage", "de": "Landschaft"},
		"name-extended": null,
		"categories": [
			{ "id": 1, "name": {"en": "biology", "fr": "biologie", "de": "Biologie"} },
			{ "id": 2, "name": {"en": "geography", "fr": "géographie", "de": "Geographie"} }
		]
	}


## GET categories

Returns the list of available categories. No paging is done but the number is included in the response. Here is an example response:

	{
		"count": 5,
		"results": [
			{ "id": 1, "name": {"en": "biology", "fr": "biologie", "de": "Biologie"} },
			{ "id": 2, "name": {"en": "geography", "fr": "géographie", "de": "Geographie"} },
			{ "id": 3, "name": {"en": "medicine", "fr": "médicine", "de": "Medizin"} },
			{ "id": 4, "name": {"en": "physics", "fr": "physique", "de": "Physik"} },
			{ "id": 5, "name": {"en": "computer science", "fr": "informatique", "de": "Informatik"} }
		]
	}

**Ordering** can be done using the `sort` and `desc` parameters. Descending sort can be done with `sort=name&desc=name`.


## JSONP

In any request a `callback` parameter can be included to get a JSONP result. E.g. `GET en/items/2?callback=mycallback` yields:

	mycallback({
		"id": 2,
		"name": {"en": "landscape", "fr": "paysage", "de": "Landschaft"},
		"name_extended": null,
		"categories": [
			{ "id": 1, "name": {"en": "biology", "fr": "biologie", "de": "Biologie"} },
			{ "id": 2, "name": {"en": "geography", "fr": "géographie", "de": "Geographie"} }
		]
	});

