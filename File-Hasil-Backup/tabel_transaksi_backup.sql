--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

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
-- Name: transaksi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaksi (
    id_transaksi integer NOT NULL,
    tanggal timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tipe character varying(20) NOT NULL,
    perubahan text,
    id_produk integer,
    id_pemasok integer,
    id_toko integer,
    id_admin integer,
    CONSTRAINT transaksi_tipe_check CHECK (((tipe)::text = ANY ((ARRAY['Masuk'::character varying, 'Keluar'::character varying, 'Produk Baru'::character varying])::text[])))
);


ALTER TABLE public.transaksi OWNER TO postgres;

--
-- Name: transaksi_id_transaksi_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transaksi_id_transaksi_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transaksi_id_transaksi_seq OWNER TO postgres;

--
-- Name: transaksi_id_transaksi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transaksi_id_transaksi_seq OWNED BY public.transaksi.id_transaksi;


--
-- Name: transaksi id_transaksi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi ALTER COLUMN id_transaksi SET DEFAULT nextval('public.transaksi_id_transaksi_seq'::regclass);


--
-- Data for Name: transaksi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaksi (id_transaksi, tanggal, tipe, perubahan, id_produk, id_pemasok, id_toko, id_admin) FROM stdin;
1	2024-12-09 17:09:11.493424	Produk Baru	Tambah produk: Laptop	\N	\N	\N	1
2	2024-12-09 17:09:19.480311	Produk Baru	Tambah produk: Kulkas	\N	\N	\N	1
3	2024-12-10 13:38:16.322229	Produk Baru	Tambah produk: Kacamata	\N	\N	\N	1
4	2024-12-10 13:38:16.322229	Produk Baru	Tambah produk: Kulkas	\N	\N	\N	1
5	2024-12-10 13:39:10.32663	Masuk	+20	1	1	\N	\N
6	2024-12-10 13:40:22.536737	Keluar	-5	1	\N	1	\N
\.


--
-- Name: transaksi_id_transaksi_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transaksi_id_transaksi_seq', 6, true);


--
-- Name: transaksi transaksi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_pkey PRIMARY KEY (id_transaksi);


--
-- Name: transaksi transaksi_id_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_id_admin_fkey FOREIGN KEY (id_admin) REFERENCES public.admin(id_admin) ON DELETE SET NULL;


--
-- Name: transaksi transaksi_id_pemasok_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_id_pemasok_fkey FOREIGN KEY (id_pemasok) REFERENCES public.pemasok(id_pemasok) ON DELETE SET NULL;


--
-- Name: transaksi transaksi_id_produk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_id_produk_fkey FOREIGN KEY (id_produk) REFERENCES public.produk(id_produk) ON DELETE SET NULL;


--
-- Name: transaksi transaksi_id_toko_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_id_toko_fkey FOREIGN KEY (id_toko) REFERENCES public.toko(id_toko) ON DELETE SET NULL;


--
-- Name: TABLE transaksi; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transaksi TO admin_role;
GRANT SELECT,INSERT,UPDATE ON TABLE public.transaksi TO toko_role;


--
-- Name: SEQUENCE transaksi_id_transaksi_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.transaksi_id_transaksi_seq TO admin_role;
GRANT SELECT,USAGE ON SEQUENCE public.transaksi_id_transaksi_seq TO toko_role;


--
-- PostgreSQL database dump complete
--

