--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: validate_geojson(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION validate_geojson(json text) RETURNS boolean
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
-- Name: advanced_searches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE advanced_searches (
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

CREATE SEQUENCE advanced_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: advanced_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE advanced_searches_id_seq OWNED BY advanced_searches.id;


--
-- Name: catalog_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE catalog_permissions (
    id integer NOT NULL,
    catalog_id integer,
    user_id integer,
    role character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: catalog_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE catalog_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalog_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE catalog_permissions_id_seq OWNED BY catalog_permissions.id;


--
-- Name: catalogs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE catalogs (
    id integer NOT NULL,
    name character varying,
    slug character varying,
    primary_language character varying DEFAULT 'en'::character varying NOT NULL,
    other_languages json,
    requires_review boolean DEFAULT false NOT NULL,
    deactivated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: catalogs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE catalogs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE catalogs_id_seq OWNED BY catalogs.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    catalog_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: choice_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE choice_sets (
    id integer NOT NULL,
    catalog_id integer,
    name character varying,
    deactivated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: choice_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE choice_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: choice_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE choice_sets_id_seq OWNED BY choice_sets.id;


--
-- Name: choices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE choices (
    id integer NOT NULL,
    choice_set_id integer,
    long_name_old text,
    short_name_old character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    short_name_translations json,
    long_name_translations json,
    catalog_id integer,
    category_id integer
);


--
-- Name: choices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE choices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: choices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE choices_id_seq OWNED BY choices.id;


--
-- Name: configurations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE configurations (
    id integer NOT NULL,
    root_mode character varying DEFAULT 'listing'::character varying NOT NULL,
    default_catalog_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE configurations_id_seq OWNED BY configurations.id;


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fields (
    id integer NOT NULL,
    field_set_id integer,
    category_item_type_id integer,
    related_item_type_id integer,
    choice_set_id integer,
    type character varying,
    name_old character varying,
    name_plural_old character varying,
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
    field_set_type character varying
);


--
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fields_id_seq OWNED BY fields.id;


--
-- Name: item_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE item_types (
    id integer NOT NULL,
    catalog_id integer,
    name_old character varying,
    slug character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name_plural_old character varying,
    name_translations json,
    name_plural_translations json
);


--
-- Name: item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE item_types_id_seq OWNED BY item_types.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE items (
    id integer NOT NULL,
    catalog_id integer,
    item_type_id integer,
    data json,
    review_status character varying DEFAULT 'not-ready'::character varying NOT NULL,
    creator_id integer,
    reviewer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    search_data_de text,
    search_data_en text,
    search_data_fr text,
    search_data_it text
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    id integer NOT NULL,
    catalog_id integer,
    creator_id integer,
    reviewer_id integer,
    slug character varying,
    title text,
    content text,
    locale character varying,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
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
    invited_by_id integer
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY advanced_searches ALTER COLUMN id SET DEFAULT nextval('advanced_searches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY catalog_permissions ALTER COLUMN id SET DEFAULT nextval('catalog_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY catalogs ALTER COLUMN id SET DEFAULT nextval('catalogs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY choice_sets ALTER COLUMN id SET DEFAULT nextval('choice_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY choices ALTER COLUMN id SET DEFAULT nextval('choices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY configurations ALTER COLUMN id SET DEFAULT nextval('configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fields ALTER COLUMN id SET DEFAULT nextval('fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_types ALTER COLUMN id SET DEFAULT nextval('item_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: advanced_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY advanced_searches
    ADD CONSTRAINT advanced_searches_pkey PRIMARY KEY (id);


--
-- Name: catalog_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY catalog_permissions
    ADD CONSTRAINT catalog_permissions_pkey PRIMARY KEY (id);


--
-- Name: catalogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY catalogs
    ADD CONSTRAINT catalogs_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: choice_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY choice_sets
    ADD CONSTRAINT choice_sets_pkey PRIMARY KEY (id);


--
-- Name: choices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY choices
    ADD CONSTRAINT choices_pkey PRIMARY KEY (id);


--
-- Name: configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY configurations
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_advanced_searches_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advanced_searches_on_catalog_id ON advanced_searches USING btree (catalog_id);


--
-- Name: index_advanced_searches_on_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_advanced_searches_on_item_type_id ON advanced_searches USING btree (item_type_id);


--
-- Name: index_catalog_permissions_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_catalog_permissions_on_catalog_id ON catalog_permissions USING btree (catalog_id);


--
-- Name: index_catalog_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_catalog_permissions_on_user_id ON catalog_permissions USING btree (user_id);


--
-- Name: index_catalogs_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_catalogs_on_slug ON catalogs USING btree (slug);


--
-- Name: index_categories_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_catalog_id ON categories USING btree (catalog_id);


--
-- Name: index_choice_sets_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_choice_sets_on_catalog_id ON choice_sets USING btree (catalog_id);


--
-- Name: index_choices_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_choices_on_catalog_id ON choices USING btree (catalog_id);


--
-- Name: index_choices_on_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_choices_on_category_id ON choices USING btree (category_id);


--
-- Name: index_choices_on_choice_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_choices_on_choice_set_id ON choices USING btree (choice_set_id);


--
-- Name: index_fields_on_category_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_category_item_type_id ON fields USING btree (category_item_type_id);


--
-- Name: index_fields_on_choice_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_choice_set_id ON fields USING btree (choice_set_id);


--
-- Name: index_fields_on_field_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_field_set_id ON fields USING btree (field_set_id);


--
-- Name: index_fields_on_field_set_id_and_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_fields_on_field_set_id_and_slug ON fields USING btree (field_set_id, slug);


--
-- Name: index_fields_on_related_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_related_item_type_id ON fields USING btree (related_item_type_id);


--
-- Name: index_item_types_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_types_on_catalog_id ON item_types USING btree (catalog_id);


--
-- Name: index_item_types_on_catalog_id_and_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_item_types_on_catalog_id_and_slug ON item_types USING btree (catalog_id, slug);


--
-- Name: index_items_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_catalog_id ON items USING btree (catalog_id);


--
-- Name: index_items_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_creator_id ON items USING btree (creator_id);


--
-- Name: index_items_on_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_item_type_id ON items USING btree (item_type_id);


--
-- Name: index_items_on_reviewer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_reviewer_id ON items USING btree (reviewer_id);


--
-- Name: index_pages_on_catalog_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pages_on_catalog_id ON pages USING btree (catalog_id);


--
-- Name: index_pages_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pages_on_creator_id ON pages USING btree (creator_id);


--
-- Name: index_pages_on_reviewer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pages_on_reviewer_id ON pages USING btree (reviewer_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_025bd80d15; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY catalog_permissions
    ADD CONSTRAINT fk_rails_025bd80d15 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_06ecc03a0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT fk_rails_06ecc03a0b FOREIGN KEY (reviewer_id) REFERENCES users(id);


--
-- Name: fk_rails_117ec28f50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advanced_searches
    ADD CONSTRAINT fk_rails_117ec28f50 FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_19ef1c4b26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY configurations
    ADD CONSTRAINT fk_rails_19ef1c4b26 FOREIGN KEY (default_catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_2ab8ce6cc4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT fk_rails_2ab8ce6cc4 FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_2cdcd0ff03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY choices
    ADD CONSTRAINT fk_rails_2cdcd0ff03 FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: fk_rails_30b4814118; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY catalog_permissions
    ADD CONSTRAINT fk_rails_30b4814118 FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_32125ce034; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_types
    ADD CONSTRAINT fk_rails_32125ce034 FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_36cea7cc6d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY choices
    ADD CONSTRAINT fk_rails_36cea7cc6d FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_58a0bde7fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY advanced_searches
    ADD CONSTRAINT fk_rails_58a0bde7fb FOREIGN KEY (item_type_id) REFERENCES item_types(id);


--
-- Name: fk_rails_630f019a5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fields
    ADD CONSTRAINT fk_rails_630f019a5a FOREIGN KEY (related_item_type_id) REFERENCES item_types(id);


--
-- Name: fk_rails_6bed0f90a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_6bed0f90a5 FOREIGN KEY (item_type_id) REFERENCES item_types(id);


--
-- Name: fk_rails_6f848ad005; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fields
    ADD CONSTRAINT fk_rails_6f848ad005 FOREIGN KEY (category_item_type_id) REFERENCES item_types(id);


--
-- Name: fk_rails_73cabaed53; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT fk_rails_73cabaed53 FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: fk_rails_abba16b043; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_abba16b043 FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: fk_rails_ac675f13b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_ac675f13b9 FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_ae14a5013f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_ae14a5013f FOREIGN KEY (invited_by_id) REFERENCES users(id);


--
-- Name: fk_rails_baa6b9a371; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY choices
    ADD CONSTRAINT fk_rails_baa6b9a371 FOREIGN KEY (choice_set_id) REFERENCES choice_sets(id);


--
-- Name: fk_rails_bf173d5998; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_bf173d5998 FOREIGN KEY (reviewer_id) REFERENCES users(id);


--
-- Name: fk_rails_e090108a07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_rails_e090108a07 FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- Name: fk_rails_fd9a6168ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fields
    ADD CONSTRAINT fk_rails_fd9a6168ac FOREIGN KEY (choice_set_id) REFERENCES choice_sets(id);


--
-- Name: fk_rails_ff3358b0ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY choice_sets
    ADD CONSTRAINT fk_rails_ff3358b0ed FOREIGN KEY (catalog_id) REFERENCES catalogs(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20151005181012');

INSERT INTO schema_migrations (version) VALUES ('20151005201520');

INSERT INTO schema_migrations (version) VALUES ('20151005203028');

INSERT INTO schema_migrations (version) VALUES ('20151005203921');

INSERT INTO schema_migrations (version) VALUES ('20151005205146');

INSERT INTO schema_migrations (version) VALUES ('20151005210132');

INSERT INTO schema_migrations (version) VALUES ('20151005221339');

INSERT INTO schema_migrations (version) VALUES ('20151007172059');

INSERT INTO schema_migrations (version) VALUES ('20151013214402');

INSERT INTO schema_migrations (version) VALUES ('20151013214815');

INSERT INTO schema_migrations (version) VALUES ('20151013232152');

INSERT INTO schema_migrations (version) VALUES ('20151013232606');

INSERT INTO schema_migrations (version) VALUES ('20151014232335');

INSERT INTO schema_migrations (version) VALUES ('20151015161910');

INSERT INTO schema_migrations (version) VALUES ('20151015214240');

INSERT INTO schema_migrations (version) VALUES ('20151015233520');

INSERT INTO schema_migrations (version) VALUES ('20151016001005');

INSERT INTO schema_migrations (version) VALUES ('20151019204634');

INSERT INTO schema_migrations (version) VALUES ('20151019205434');

INSERT INTO schema_migrations (version) VALUES ('20151020171305');

INSERT INTO schema_migrations (version) VALUES ('20151021003024');

INSERT INTO schema_migrations (version) VALUES ('20151027162712');

INSERT INTO schema_migrations (version) VALUES ('20151027173025');

INSERT INTO schema_migrations (version) VALUES ('20151027213627');

INSERT INTO schema_migrations (version) VALUES ('20151027221141');

INSERT INTO schema_migrations (version) VALUES ('20151028165346');

INSERT INTO schema_migrations (version) VALUES ('20151028165822');

INSERT INTO schema_migrations (version) VALUES ('20151102213009');

INSERT INTO schema_migrations (version) VALUES ('20151105175029');

INSERT INTO schema_migrations (version) VALUES ('20151106003745');

INSERT INTO schema_migrations (version) VALUES ('20151109224327');

INSERT INTO schema_migrations (version) VALUES ('20151130193143');

INSERT INTO schema_migrations (version) VALUES ('20151130214821');

INSERT INTO schema_migrations (version) VALUES ('20151205003146');

INSERT INTO schema_migrations (version) VALUES ('20151205005311');

INSERT INTO schema_migrations (version) VALUES ('20151205011325');

INSERT INTO schema_migrations (version) VALUES ('20151206234336');

INSERT INTO schema_migrations (version) VALUES ('20151210000035');

INSERT INTO schema_migrations (version) VALUES ('20151212000308');

