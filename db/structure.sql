SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: bigdate_to_num(json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.bigdate_to_num(json) RETURNS numeric
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT (
            CASE WHEN $1->>'Y' IS NULL THEN 0 ELSE ($1->>'Y')::INTEGER * POWER(10, 10) END +
            CASE WHEN $1->>'M' IS NULL THEN 0 ELSE ($1->>'M')::INTEGER * POWER(10, 8) END +
            CASE WHEN $1->>'D' IS NULL THEN 0 ELSE ($1->>'D')::INTEGER * POWER(10, 6) END +
            CASE WHEN $1->>'h' IS NULL THEN 0 ELSE ($1->>'h')::INTEGER * POWER(10, 4) END +
            CASE WHEN $1->>'m' IS NULL THEN 0 ELSE ($1->>'m')::INTEGER * POWER(10, 2) END +
            CASE WHEN $1->>'s' IS NULL THEN 0 ELSE ($1->>'s')::INTEGER END
          )::NUMERIC;$_$;


--
-- Name: validate_geojson(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_geojson(json text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RETURN ST_IsValid(ST_GeomFromGeoJSON(json));
      EXCEPTION WHEN others THEN
        RETURN 'f';
      END;
      $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: advanced_search_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.advanced_search_configurations (
    id bigint NOT NULL,
    item_type_id bigint,
    catalog_id bigint,
    creator_id integer,
    title_translations jsonb,
    description jsonb,
    slug character varying,
    search_type character varying DEFAULT 'default'::character varying,
    fields jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: advanced_search_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.advanced_search_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advanced_search_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.advanced_search_configurations_id_seq OWNED BY public.advanced_search_configurations.id;


--
-- Name: advanced_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.advanced_searches (
    id integer NOT NULL,
    uuid character varying,
    item_type_id integer,
    catalog_id integer,
    creator_id integer,
    criteria json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locale character varying DEFAULT 'en'::character varying NOT NULL
);


--
-- Name: advanced_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.advanced_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advanced_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.advanced_searches_id_seq OWNED BY public.advanced_searches.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: catalog_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalog_permissions (
    id integer NOT NULL,
    catalog_id integer,
    user_id integer,
    role character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id integer
);


--
-- Name: catalog_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.catalog_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalog_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.catalog_permissions_id_seq OWNED BY public.catalog_permissions.id;


--
-- Name: catalogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalogs (
    id integer NOT NULL,
    name character varying,
    slug character varying,
    primary_language character varying DEFAULT 'en'::character varying NOT NULL,
    other_languages json,
    requires_review boolean DEFAULT false NOT NULL,
    deactivated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    custom_root_page_id integer,
    advertize boolean,
    style jsonb,
    logo_id character varying,
    navlogo_id character varying,
    visible boolean DEFAULT true NOT NULL,
    restricted boolean DEFAULT false NOT NULL
);


--
-- Name: catalogs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.catalogs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.catalogs_id_seq OWNED BY public.catalogs.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    catalog_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    deactivated_at timestamp without time zone,
    uuid character varying
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: choice_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.choice_sets (
    id integer NOT NULL,
    catalog_id integer,
    name character varying,
    deactivated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying,
    uuid character varying
);


--
-- Name: choice_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.choice_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: choice_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.choice_sets_id_seq OWNED BY public.choice_sets.id;


--
-- Name: choices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.choices (
    id integer NOT NULL,
    choice_set_id integer,
    long_name_old text,
    short_name_old character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    short_name_translations json,
    long_name_translations json,
    catalog_id integer,
    category_id integer,
    uuid character varying,
    parent_id bigint
);


--
-- Name: choices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.choices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: choices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.choices_id_seq OWNED BY public.choices.id;


--
-- Name: configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configurations (
    id integer NOT NULL,
    root_mode character varying DEFAULT 'listing'::character varying NOT NULL,
    default_catalog_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configurations_id_seq OWNED BY public.configurations.id;


--
-- Name: containers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.containers (
    id integer NOT NULL,
    page_id integer,
    type character varying,
    slug character varying,
    row_order integer,
    content jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locale character varying
);


--
-- Name: containers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.containers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: containers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.containers_id_seq OWNED BY public.containers.id;


--
-- Name: exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exports (
    id integer NOT NULL,
    user_id integer,
    catalog_id integer,
    category character varying,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exports_id_seq OWNED BY public.exports.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id integer NOT NULL,
    user_id integer,
    item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fields (
    id integer NOT NULL,
    field_set_id integer,
    category_item_type_id integer,
    related_item_type_id integer,
    choice_set_id integer,
    type character varying,
    slug character varying,
    comment text,
    multiple boolean DEFAULT false NOT NULL,
    ordered boolean DEFAULT false NOT NULL,
    required boolean DEFAULT true NOT NULL,
    i18n boolean DEFAULT false NOT NULL,
    "unique" boolean DEFAULT false NOT NULL,
    default_value text,
    options json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    display_in_list boolean DEFAULT true NOT NULL,
    row_order integer,
    uuid character varying,
    name_translations json,
    name_plural_translations json,
    field_set_type character varying,
    editor_component character varying,
    display_component character varying,
    display_in_public_list boolean DEFAULT true NOT NULL,
    restricted boolean DEFAULT false NOT NULL
);


--
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fields_id_seq OWNED BY public.fields.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying,
    description character varying,
    public boolean,
    owner_id bigint NOT NULL,
    active boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    catalog_id bigint,
    identifier character varying
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: item_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_types (
    id integer NOT NULL,
    catalog_id integer,
    slug character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name_translations json,
    name_plural_translations json,
    deactivated_at timestamp without time zone,
    display_emtpy_fields boolean DEFAULT true NOT NULL
);


--
-- Name: item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_types_id_seq OWNED BY public.item_types.id;


--
-- Name: item_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.item_views (
    id integer NOT NULL,
    name character varying,
    item_type_id integer,
    template jsonb,
    default_for_list_view boolean,
    default_for_item_view boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    default_for_display_name boolean DEFAULT false
);


--
-- Name: item_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.item_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.item_views_id_seq OWNED BY public.item_views.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id integer NOT NULL,
    catalog_id integer,
    item_type_id integer,
    data jsonb,
    review_status character varying DEFAULT 'not-ready'::character varying NOT NULL,
    creator_id integer,
    reviewer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    search_data_de text,
    search_data_en text,
    search_data_fr text,
    search_data_it text,
    uuid character varying,
    views jsonb,
    updater_id integer
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    user_id bigint,
    group_id bigint,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: menu_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_items (
    id integer NOT NULL,
    catalog_id integer,
    slug character varying,
    title_old character varying,
    item_type_id integer,
    page_id integer,
    url_old text,
    parent_id integer,
    rank integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title jsonb,
    url jsonb
);


--
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menu_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menu_items_id_seq OWNED BY public.menu_items.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id integer NOT NULL,
    catalog_id integer,
    creator_id integer,
    reviewer_id integer,
    slug character varying,
    title_old text,
    locale_old character varying,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title jsonb
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: template_storages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_storages (
    id integer NOT NULL,
    body text,
    path character varying,
    locale character varying,
    handler character varying,
    partial boolean,
    format character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: template_storages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.template_storages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_storages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.template_storages_id_seq OWNED BY public.template_storages.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    system_admin boolean DEFAULT false NOT NULL,
    primary_language character varying DEFAULT 'en'::character varying NOT NULL,
    invited_by_id integer,
    provider character varying,
    uid character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: advanced_search_configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_search_configurations ALTER COLUMN id SET DEFAULT nextval('public.advanced_search_configurations_id_seq'::regclass);


--
-- Name: advanced_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_searches ALTER COLUMN id SET DEFAULT nextval('public.advanced_searches_id_seq'::regclass);


--
-- Name: catalog_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_permissions ALTER COLUMN id SET DEFAULT nextval('public.catalog_permissions_id_seq'::regclass);


--
-- Name: catalogs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalogs ALTER COLUMN id SET DEFAULT nextval('public.catalogs_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: choice_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choice_sets ALTER COLUMN id SET DEFAULT nextval('public.choice_sets_id_seq'::regclass);


--
-- Name: choices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choices ALTER COLUMN id SET DEFAULT nextval('public.choices_id_seq'::regclass);


--
-- Name: configurations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configurations ALTER COLUMN id SET DEFAULT nextval('public.configurations_id_seq'::regclass);


--
-- Name: containers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.containers ALTER COLUMN id SET DEFAULT nextval('public.containers_id_seq'::regclass);


--
-- Name: exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports ALTER COLUMN id SET DEFAULT nextval('public.exports_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields ALTER COLUMN id SET DEFAULT nextval('public.fields_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: item_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_types ALTER COLUMN id SET DEFAULT nextval('public.item_types_id_seq'::regclass);


--
-- Name: item_views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_views ALTER COLUMN id SET DEFAULT nextval('public.item_views_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: menu_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items ALTER COLUMN id SET DEFAULT nextval('public.menu_items_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: template_storages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_storages ALTER COLUMN id SET DEFAULT nextval('public.template_storages_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: advanced_search_configurations advanced_search_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_search_configurations
    ADD CONSTRAINT advanced_search_configurations_pkey PRIMARY KEY (id);


--
-- Name: advanced_searches advanced_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_searches
    ADD CONSTRAINT advanced_searches_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: catalog_permissions catalog_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_permissions
    ADD CONSTRAINT catalog_permissions_pkey PRIMARY KEY (id);


--
-- Name: catalogs catalogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalogs
    ADD CONSTRAINT catalogs_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: choice_sets choice_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choice_sets
    ADD CONSTRAINT choice_sets_pkey PRIMARY KEY (id);


--
-- Name: choices choices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choices
    ADD CONSTRAINT choices_pkey PRIMARY KEY (id);


--
-- Name: configurations configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configurations
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: containers containers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT containers_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- Name: item_views item_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_views
    ADD CONSTRAINT item_views_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: template_storages template_storages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_storages
    ADD CONSTRAINT template_storages_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_advanced_search_configurations_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advanced_search_configurations_on_catalog_id ON public.advanced_search_configurations USING btree (catalog_id);


--
-- Name: index_advanced_search_configurations_on_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advanced_search_configurations_on_item_type_id ON public.advanced_search_configurations USING btree (item_type_id);


--
-- Name: index_advanced_search_configurations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advanced_search_configurations_on_slug ON public.advanced_search_configurations USING btree (slug);


--
-- Name: index_advanced_searches_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advanced_searches_on_catalog_id ON public.advanced_searches USING btree (catalog_id);


--
-- Name: index_advanced_searches_on_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_advanced_searches_on_item_type_id ON public.advanced_searches USING btree (item_type_id);


--
-- Name: index_catalog_permissions_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_catalog_permissions_on_catalog_id ON public.catalog_permissions USING btree (catalog_id);


--
-- Name: index_catalog_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_catalog_permissions_on_user_id ON public.catalog_permissions USING btree (user_id);


--
-- Name: index_catalogs_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_catalogs_on_slug ON public.catalogs USING btree (slug);


--
-- Name: index_categories_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_catalog_id ON public.categories USING btree (catalog_id);


--
-- Name: index_categories_on_uuid_and_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_uuid_and_catalog_id ON public.categories USING btree (uuid, catalog_id);


--
-- Name: index_choice_sets_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_choice_sets_on_catalog_id ON public.choice_sets USING btree (catalog_id);


--
-- Name: index_choice_sets_on_uuid_and_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_choice_sets_on_uuid_and_catalog_id ON public.choice_sets USING btree (uuid, catalog_id);


--
-- Name: index_choices_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_choices_on_catalog_id ON public.choices USING btree (catalog_id);


--
-- Name: index_choices_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_choices_on_category_id ON public.choices USING btree (category_id);


--
-- Name: index_choices_on_choice_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_choices_on_choice_set_id ON public.choices USING btree (choice_set_id);


--
-- Name: index_choices_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_choices_on_parent_id ON public.choices USING btree (parent_id);


--
-- Name: index_choices_on_uuid_and_choice_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_choices_on_uuid_and_choice_set_id ON public.choices USING btree (uuid, choice_set_id);


--
-- Name: index_containers_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_containers_on_page_id ON public.containers USING btree (page_id);


--
-- Name: index_containers_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_containers_on_slug ON public.containers USING btree (slug);


--
-- Name: index_exports_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_catalog_id ON public.exports USING btree (catalog_id);


--
-- Name: index_exports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exports_on_user_id ON public.exports USING btree (user_id);


--
-- Name: index_favorites_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_item_id ON public.favorites USING btree (item_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_user_id ON public.favorites USING btree (user_id);


--
-- Name: index_fields_on_category_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fields_on_category_item_type_id ON public.fields USING btree (category_item_type_id);


--
-- Name: index_fields_on_choice_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fields_on_choice_set_id ON public.fields USING btree (choice_set_id);


--
-- Name: index_fields_on_field_set_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fields_on_field_set_id ON public.fields USING btree (field_set_id);


--
-- Name: index_fields_on_field_set_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_fields_on_field_set_id_and_slug ON public.fields USING btree (field_set_id, slug);


--
-- Name: index_fields_on_related_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fields_on_related_item_type_id ON public.fields USING btree (related_item_type_id);


--
-- Name: index_groups_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_catalog_id ON public.groups USING btree (catalog_id);


--
-- Name: index_groups_on_name_and_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_name_and_catalog_id ON public.groups USING btree (name, catalog_id);


--
-- Name: index_groups_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_owner_id ON public.groups USING btree (owner_id);


--
-- Name: index_item_types_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_types_on_catalog_id ON public.item_types USING btree (catalog_id);


--
-- Name: index_item_types_on_catalog_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_item_types_on_catalog_id_and_slug ON public.item_types USING btree (catalog_id, slug);


--
-- Name: index_item_views_on_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_views_on_item_type_id ON public.item_views USING btree (item_type_id);


--
-- Name: index_items_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_catalog_id ON public.items USING btree (catalog_id);


--
-- Name: index_items_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_creator_id ON public.items USING btree (creator_id);


--
-- Name: index_items_on_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_item_type_id ON public.items USING btree (item_type_id);


--
-- Name: index_items_on_reviewer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_reviewer_id ON public.items USING btree (reviewer_id);


--
-- Name: index_items_on_uuid_and_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_items_on_uuid_and_catalog_id ON public.items USING btree (uuid, catalog_id);


--
-- Name: index_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_group_id ON public.memberships USING btree (group_id);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_user_id ON public.memberships USING btree (user_id);


--
-- Name: index_menu_items_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_items_on_catalog_id ON public.menu_items USING btree (catalog_id);


--
-- Name: index_menu_items_on_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_items_on_item_type_id ON public.menu_items USING btree (item_type_id);


--
-- Name: index_menu_items_on_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_items_on_page_id ON public.menu_items USING btree (page_id);


--
-- Name: index_menu_items_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_menu_items_on_parent_id ON public.menu_items USING btree (parent_id);


--
-- Name: index_pages_on_catalog_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_catalog_id ON public.pages USING btree (catalog_id);


--
-- Name: index_pages_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_creator_id ON public.pages USING btree (creator_id);


--
-- Name: index_pages_on_reviewer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pages_on_reviewer_id ON public.pages USING btree (reviewer_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: catalog_permissions fk_rails_025bd80d15; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_permissions
    ADD CONSTRAINT fk_rails_025bd80d15 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pages fk_rails_06ecc03a0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_06ecc03a0b FOREIGN KEY (reviewer_id) REFERENCES public.users(id);


--
-- Name: menu_items fk_rails_0bf5ba9c7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT fk_rails_0bf5ba9c7e FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: advanced_searches fk_rails_117ec28f50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_searches
    ADD CONSTRAINT fk_rails_117ec28f50 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: configurations fk_rails_19ef1c4b26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configurations
    ADD CONSTRAINT fk_rails_19ef1c4b26 FOREIGN KEY (default_catalog_id) REFERENCES public.catalogs(id);


--
-- Name: exports fk_rails_26b155474a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT fk_rails_26b155474a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pages fk_rails_2ab8ce6cc4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_2ab8ce6cc4 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: choices fk_rails_2cdcd0ff03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choices
    ADD CONSTRAINT fk_rails_2cdcd0ff03 FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: favorites fk_rails_30ac764a96; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_30ac764a96 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: catalog_permissions fk_rails_30b4814118; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_permissions
    ADD CONSTRAINT fk_rails_30b4814118 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: item_types fk_rails_32125ce034; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_types
    ADD CONSTRAINT fk_rails_32125ce034 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: choices fk_rails_36cea7cc6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choices
    ADD CONSTRAINT fk_rails_36cea7cc6d FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: groups fk_rails_5447bdb9c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_5447bdb9c5 FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: menu_items fk_rails_55a0ee63e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT fk_rails_55a0ee63e5 FOREIGN KEY (parent_id) REFERENCES public.menu_items(id);


--
-- Name: advanced_searches fk_rails_58a0bde7fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_searches
    ADD CONSTRAINT fk_rails_58a0bde7fb FOREIGN KEY (item_type_id) REFERENCES public.item_types(id);


--
-- Name: groups fk_rails_59e1c2c1e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_59e1c2c1e9 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: fields fk_rails_630f019a5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fk_rails_630f019a5a FOREIGN KEY (related_item_type_id) REFERENCES public.item_types(id);


--
-- Name: items fk_rails_6bed0f90a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_6bed0f90a5 FOREIGN KEY (item_type_id) REFERENCES public.item_types(id);


--
-- Name: fields fk_rails_6f848ad005; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fk_rails_6f848ad005 FOREIGN KEY (category_item_type_id) REFERENCES public.item_types(id);


--
-- Name: menu_items fk_rails_7075222f77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT fk_rails_7075222f77 FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- Name: catalogs fk_rails_72a75a77ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalogs
    ADD CONSTRAINT fk_rails_72a75a77ca FOREIGN KEY (custom_root_page_id) REFERENCES public.pages(id);


--
-- Name: pages fk_rails_73cabaed53; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT fk_rails_73cabaed53 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: exports fk_rails_7563b31b52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT fk_rails_7563b31b52 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: containers fk_rails_8a017573a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.containers
    ADD CONSTRAINT fk_rails_8a017573a6 FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- Name: item_views fk_rails_9310522ec6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.item_views
    ADD CONSTRAINT fk_rails_9310522ec6 FOREIGN KEY (item_type_id) REFERENCES public.item_types(id);


--
-- Name: advanced_search_configurations fk_rails_9526ee702d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_search_configurations
    ADD CONSTRAINT fk_rails_9526ee702d FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: memberships fk_rails_99326fb65d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_99326fb65d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: memberships fk_rails_aaf389f138; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_aaf389f138 FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: items fk_rails_ac675f13b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_ac675f13b9 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: users fk_rails_ae14a5013f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_ae14a5013f FOREIGN KEY (invited_by_id) REFERENCES public.users(id);


--
-- Name: choices fk_rails_baa6b9a371; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choices
    ADD CONSTRAINT fk_rails_baa6b9a371 FOREIGN KEY (choice_set_id) REFERENCES public.choice_sets(id);


--
-- Name: menu_items fk_rails_d05e957707; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT fk_rails_d05e957707 FOREIGN KEY (item_type_id) REFERENCES public.item_types(id);


--
-- Name: advanced_search_configurations fk_rails_d069211577; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.advanced_search_configurations
    ADD CONSTRAINT fk_rails_d069211577 FOREIGN KEY (item_type_id) REFERENCES public.item_types(id);


--
-- Name: favorites fk_rails_d15744e438; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_d15744e438 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: categories fk_rails_e090108a07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_e090108a07 FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- Name: fields fk_rails_fd9a6168ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fields
    ADD CONSTRAINT fk_rails_fd9a6168ac FOREIGN KEY (choice_set_id) REFERENCES public.choice_sets(id);


--
-- Name: choice_sets fk_rails_ff3358b0ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.choice_sets
    ADD CONSTRAINT fk_rails_ff3358b0ed FOREIGN KEY (catalog_id) REFERENCES public.catalogs(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20151005181012'),
('20151005201520'),
('20151005203028'),
('20151005203921'),
('20151005205146'),
('20151005210132'),
('20151005221339'),
('20151007172059'),
('20151013214402'),
('20151013214815'),
('20151013232152'),
('20151013232606'),
('20151014232335'),
('20151015161910'),
('20151015214240'),
('20151015233520'),
('20151016001005'),
('20151019204634'),
('20151019205434'),
('20151020171305'),
('20151021003024'),
('20151027162712'),
('20151027173025'),
('20151027213627'),
('20151027221141'),
('20151028165346'),
('20151028165822'),
('20151102213009'),
('20151105175029'),
('20151106003745'),
('20151109224327'),
('20151130193143'),
('20151130214821'),
('20151205003146'),
('20151205005311'),
('20151205011325'),
('20151206234336'),
('20151212000308'),
('20151214213046'),
('20160307163846'),
('20160425072020'),
('20160425125350'),
('20160509095147'),
('20160509194619'),
('20160720053135'),
('20170121055843'),
('20170507231151'),
('20170507231610'),
('20170513155612'),
('20170513160403'),
('20170705191550'),
('20170830180816'),
('20170830181451'),
('20170830182339'),
('20170831075823'),
('20170913085323'),
('20170926095141'),
('20171106080707'),
('20171109063607'),
('20171118121553'),
('20171205064929'),
('20171214171741'),
('20171216182821'),
('20171219054741'),
('20180220093412'),
('20180308085259'),
('20180504082040'),
('20180615090214'),
('20180702145421'),
('20180822150656'),
('20180907111339'),
('20180918114846'),
('20180919104449'),
('20180920073829'),
('20180922224350'),
('20180923135339'),
('20180923135401'),
('20180925152745'),
('20181022124602'),
('20181207103025'),
('20181207145518'),
('20181210123619'),
('20181214095728');


