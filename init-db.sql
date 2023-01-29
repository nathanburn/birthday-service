--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users; Type: TABLE; Schema: public; Owner: birthday-service-user
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    created_timestamp timestamp(6) with time zone,
    date_of_birth date,
    updated_timestamp timestamp(6) with time zone,
    username character varying(255),
    version bigint
);


ALTER TABLE public.users OWNER TO "birthday-service-user";

--
-- Name: users_seq; Type: SEQUENCE; Schema: public; Owner: birthday-service-user
--

CREATE SEQUENCE public.users_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_seq OWNER TO "birthday-service-user";

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: birthday-service-user
--

COPY public.users (id, created_timestamp, date_of_birth, updated_timestamp, username, version) FROM stdin;
1	2023-01-29 20:27:05.151583+00	2000-07-01	2023-01-29 20:27:05.151638+00	bob	0
2	2023-01-29 20:27:24.101379+00	1986-01-31	2023-01-29 20:27:24.101395+00	george	0
3	2023-01-29 20:27:41.47169+00	1990-09-22	2023-01-29 20:28:07.293932+00	debs	1
\.


--
-- Name: users_seq; Type: SEQUENCE SET; Schema: public; Owner: birthday-service-user
--

SELECT pg_catalog.setval('public.users_seq', 51, true);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: birthday-service-user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

