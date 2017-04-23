# Catima API

All API routes are public (no authentication needed) and return `application/json` responses. The API is read-only.

Where applicable, resources have `_links` to related resources; this includes the URL of the user-facing `html` version of the resource.

API reference:

* [Catalogs](#catalogs)
* [Items](#items)

## Catalogs

### `GET /api/v1/catalogs?page_number=1&page_size=25`

Returns an array of all active catalogs. The result is paginated based on query parameters. By default, the page size is 25, with a maximum page size of 100.

```json
{
    "catalogs": [
        {
            "_links": {
                "html": "http://localhost:3000/library",
                "items": "http://localhost:3000/api/v1/catalogs/library/items",
                "self": "http://localhost:3000/api/v1/catalogs/library"
            },
            "advertize": false,
            "item_types": [
                {
                    "_links": {
                        "items": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book"
                    },
                    "fields": [
                        {
                            "i18n": false,
                            "label": {
                                "en": "Author"
                            },
                            "multiple": false,
                            "type": "text",
                            "uuid": "_7e08da1f_df0a_49dc_a30c_ace337a383b7"
                        },
                        {
                            "i18n": false,
                            "label": {
                                "en": "Genre"
                            },
                            "multiple": false,
                            "type": "text",
                            "uuid": "_38abc5c3_8346_46f9_90b1_c8e20e0e7803"
                        },
                        {
                            "i18n": false,
                            "label": {
                                "en": "Publisher"
                            },
                            "multiple": false,
                            "type": "text",
                            "uuid": "_8d80ab09_7f99_4984_a2d3_6776b53dcd76"
                        },
                        {
                            "i18n": false,
                            "label": {
                                "en": "Title"
                            },
                            "multiple": false,
                            "type": "text",
                            "uuid": "_b0199519_35ab_4d9b_a68c_65a704d769c5"
                        }
                    ],
                    "id": 1,
                    "name": {
                        "en": "Book"
                    },
                    "name_plural": {
                        "en": "Books"
                    },
                    "slug": "book"
                }
            ],
            "name": "Library",
            "other_languages": [],
            "primary_language": "en",
            "slug": "library"
        }
    ],
    "_links": {
        "first": "http://localhost:3000/api/v1/catalogs?page_number=1&page_size=25",
        "last": "http://localhost:3000/api/v1/catalogs?page_number=2&page_size=25",
        "next": "http://localhost:3000/api/v1/catalogs?page_number=2&page_size=25",
        "prev": null
    },
    "page_number": 1,
    "page_size": 25,
    "total_count": 26,
    "total_pages": 2
}
```

### `GET /api/v1/catalogs/:catalog_slug`

Returns a JSON representation of a catalog identified by its `slug`.

```json
{
    "_links": {
        "html": "http://localhost:3000/library",
        "items": "http://localhost:3000/api/v1/catalogs/library/items",
        "self": "http://localhost:3000/api/v1/catalogs/library"
    },
    "advertize": false,
    "item_types": [
        {
            "_links": {
                "items": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book"
            },
            "fields": [
                {
                    "i18n": false,
                    "label": {
                        "en": "Author"
                    },
                    "multiple": false,
                    "type": "text",
                    "uuid": "_7e08da1f_df0a_49dc_a30c_ace337a383b7"
                },
                {
                    "i18n": false,
                    "label": {
                        "en": "Genre"
                    },
                    "multiple": false,
                    "type": "text",
                    "uuid": "_38abc5c3_8346_46f9_90b1_c8e20e0e7803"
                },
                {
                    "i18n": false,
                    "label": {
                        "en": "Publisher"
                    },
                    "multiple": false,
                    "type": "text",
                    "uuid": "_8d80ab09_7f99_4984_a2d3_6776b53dcd76"
                },
                {
                    "i18n": false,
                    "label": {
                        "en": "Title"
                    },
                    "multiple": false,
                    "type": "text",
                    "uuid": "_b0199519_35ab_4d9b_a68c_65a704d769c5"
                }
            ],
            "id": 1,
            "name": {
                "en": "Book"
            },
            "name_plural": {
                "en": "Books"
            },
            "slug": "book"
        }
    ],
    "name": "Library",
    "other_languages": [],
    "primary_language": "en",
    "slug": "library"
}
```

## Items

### `GET /api/v1/catalogs/:catalog_slug/items?page_number=1&page_size=25`

Returns an array of all items for a given catalog The result is paginated based on query parameters. By default, the page size is 25, with a maximum page size of 100..

```json
{
    "items": [
        {
            "_links": {
                "catalog": "http://localhost:3000/api/v1/catalogs/library",
                "html": "http://localhost:3000/library/en/book/999-le-siecle-de-la-rue",
                "self": "http://localhost:3000/api/v1/catalogs/library/items/999"
            },
            "attributes": {
                "_38abc5c3_8346_46f9_90b1_c8e20e0e7803": "Folklore",
                "_7e08da1f_df0a_49dc_a30c_ace337a383b7": "Francois Lina",
                "_8d80ab09_7f99_4984_a2d3_6776b53dcd76": "La Perdrix",
                "_b0199519_35ab_4d9b_a68c_65a704d769c5": "Le Siècle de la rue voisine"
            },
            "created_at": "2017-01-24T18:12:45.530+01:00",
            "id": 999,
            "item_type_id": 1,
            "updated_at": "2017-01-24T18:12:45.530+01:00"
        }
    ],
    "_links": {
        "first": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book&page_number=1&page_size=25",
        "last": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book&page_number=40&page_size=25",
        "next": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book&page_number=2&page_size=25",
        "prev": null
    },
    "page_number": 1,
    "page_size": 25,
    "total_count": 1000,
    "total_pages": 40
}
```

### `GET /api/v1/catalogs/:catalog_slug/items/:id?item_type=:item_type_slug&page_number=1&page_size=25`

Returns an array of all items belonging to a catalog that have the specified item type. If the item type doesn't exist, a 400 error is returned. The result is paginated based on query parameters.

```json
{
    "items": [
        {
            "_links": {
                "catalog": "http://localhost:3000/api/v1/catalogs/library",
                "html": "http://localhost:3000/library/en/book/1-la-discipline-des-or",
                "self": "http://localhost:3000/api/v1/catalogs/library/items/1"
            },
            "attributes": {
                "_38abc5c3_8346_46f9_90b1_c8e20e0e7803": "Metafiction",
                "_7e08da1f_df0a_49dc_a30c_ace337a383b7": "Mme Ethan Fournier",
                "_8d80ab09_7f99_4984_a2d3_6776b53dcd76": "Au lecteur éclairé",
                "_b0199519_35ab_4d9b_a68c_65a704d769c5": "La Discipline des orphelins"
            },
            "created_at": "2017-01-24T18:12:09.163+01:00",
            "id": 1,
            "item_type_id": 1,
            "updated_at": "2017-01-24T18:12:09.163+01:00"
        }
    ],
    "_links": {
        "first": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book&page_number=1&page_size=25",
        "last": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book&page_number=40&page_size=25",
        "next": "http://localhost:3000/api/v1/catalogs/library/items?item_type=book&page_number=2&page_size=25",
        "prev": null
    },
    "page_number": 1,
    "page_size": 25,
    "total_count": 1000,
    "total_pages": 40
}
```

### `GET /api/v1/catalogs/:catalog_slug/items/:id`

Returns a JSON representation of an item identified by its ID.

```json
{
    "_links": {
        "catalog": "http://localhost:3000/api/v1/catalogs/library",
        "html": "http://localhost:3000/library/en/book/1-la-discipline-des-or",
        "self": "http://localhost:3000/api/v1/catalogs/library/items/1"
    },
    "attributes": {
        "_38abc5c3_8346_46f9_90b1_c8e20e0e7803": "Metafiction",
        "_7e08da1f_df0a_49dc_a30c_ace337a383b7": "Mme Ethan Fournier",
        "_8d80ab09_7f99_4984_a2d3_6776b53dcd76": "Au lecteur éclairé",
        "_b0199519_35ab_4d9b_a68c_65a704d769c5": "La Discipline des orphelins"
    },
    "created_at": "2017-01-24T18:12:09.163+01:00",
    "id": 1,
    "item_type_id": 1,
    "updated_at": "2017-01-24T18:12:09.163+01:00"
}
```
