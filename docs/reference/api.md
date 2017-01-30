# Catima API

All API routes are public (no authentication needed) and return `application/json` responses. The API is read-only.

Where applicable, resources have `_links` to related resources; this includes the URL of the user-facing `html` version of the resource.

API reference:

* [Catalogs](#catalogs)
* [Items](#items)
* [Pages](#pages)

## Catalogs

### `GET /api/v1/catalogs`

Returns an array of all active catalogs.

```
[
    {
        "_links": {
            "html": "http://localhost:3000/library",
            "pages": "http://localhost:3000/api/v1/catalogs/library/pages",
            "self": "http://localhost:3000/api/v1/catalogs/library"
        },
        "advertize": false,
        "item_types": [
            {
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
]
```

### `GET /api/v1/catalogs/:catalog_slug`

Returns a JSON representation of a catalog identified by its `slug`.

```
{
    "_links": {
        "html": "http://localhost:3000/library",
        "pages": "http://localhost:3000/api/v1/catalogs/library/pages",
        "self": "http://localhost:3000/api/v1/catalogs/library"
    },
    "advertize": false,
    "item_types": [
        {
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

### `GET /api/v1/catalogs/:catalog_slug/items`

TODO

### `GET /api/v1/catalogs/:catalog_slug/items/:id?item_type=:item_type_slug`

TODO

### `GET /api/v1/catalogs/:catalog_slug/items/:id`

TODO

## Pages

### `GET /api/v1/catalogs/:catalog_slug/pages`

Returns an array of all pages belonging to a catalog. The catalog is identified by its `slug`.

```
[
    {
        "_links": {
            "html": "http://localhost:3000/library/en/hello",
            "self": "http://localhost:3000/api/v1/catalogs/library/pages/2"
        },
        "catalog": {
            "_links": {
                "self": "http://localhost:3000/api/v1/catalogs/library"
            },
            "slug": "library"
        },
        "id": 2,
        "locale": "en",
        "slug": "hello",
        "title": "Hello!"
    }
]
```

### `GET /api/v1/catalogs/:catalog_slug/pages/:id`

Returns a JSON representation of a page, including its complete contents and all of its containers.

TODO

```
{
    "_links": {
        "html": "http://localhost:3000/library/en/hello",
        "self": "http://localhost:3000/api/v1/catalogs/library/pages/2"
    },
    "catalog": {
        "_links": {
            "self": "http://localhost:3000/api/v1/catalogs/library"
        },
        "slug": "library"
    },
    "id": 2,
    "containers": [],
    "content": "",
    "locale": "en",
    "slug": "hello",
    "title": "Hello!"
}
```
