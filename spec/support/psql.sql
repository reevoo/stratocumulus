DROP DATABASE stratocumulus_test;
CREATE DATABASE stratocumulus_test
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;
\c stratocumulus_test
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
SET search_path = public, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;
CREATE TABLE widgets (
    id integer NOT NULL,
    name text,
    leavers integer,
    pivots integer,
    fulcrums integer
);
ALTER TABLE public.widgets OWNER TO postgres;
CREATE SEQUENCE widgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE public.widgets_id_seq OWNER TO postgres;
ALTER SEQUENCE widgets_id_seq OWNED BY widgets.id;
ALTER TABLE ONLY widgets ALTER COLUMN id SET DEFAULT nextval('widgets_id_seq'::regclass);
COPY widgets (id, name, leavers, pivots, fulcrums) FROM stdin;
1	Foo	3	1	2
2	Bar	2	2	0
3	Baz	5	6	4
4	Qux	4	5	6
5	Quux	8	5	4
6	Corge	8	2	7
7	Grault	7	3	4
8	Garply	1	2	3
9	Waldo	0	0	0
10	Fred	1	1	1
11	Xyzzy	3	3	3
12	Thud	1	2	3
\.
SELECT pg_catalog.setval('widgets_id_seq', 12, true);
ALTER TABLE ONLY widgets
    ADD CONSTRAINT widgets_pkey PRIMARY KEY (id);
