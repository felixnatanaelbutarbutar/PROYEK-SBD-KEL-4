--
-- PostgreSQL database dump
-- f

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

--
-- Name: tambah_produk(character varying, character varying, double precision, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.tambah_produk(IN p_nama_produk character varying, IN p_kategori character varying, IN p_harga double precision, IN p_stok integer, IN p_id_admin integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validasi kategori
    IF NOT (p_kategori IN ('Elektronik', 'Pakaian', 'Makanan', 'Minuman', 'Lainnya')) THEN
        RAISE EXCEPTION 'Kategori tidak valid.';
    END IF;

    -- Tambahkan produk ke tabel Produk
    INSERT INTO Produk (nama_produk, kategori, harga, stok)
    VALUES (p_nama_produk, p_kategori, p_harga, p_stok);

    -- Catat transaksi untuk produk baru
    INSERT INTO Transaksi (tipe, perubahan, id_admin, tanggal)
    VALUES ('Produk Baru', CONCAT('Tambah produk: ', p_nama_produk), p_id_admin, CURRENT_TIMESTAMP);
END;
$$;


ALTER PROCEDURE public.tambah_produk(IN p_nama_produk character varying, IN p_kategori character varying, IN p_harga double precision, IN p_stok integer, IN p_id_admin integer) OWNER TO postgres;

--
-- Name: tambah_stok(integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.tambah_stok(IN p_id_produk integer, IN p_jumlah integer, IN p_id_pemasok integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Validasi jumlah stok
    IF p_jumlah <= 0 THEN
        RAISE EXCEPTION 'Jumlah stok yang ditambahkan harus lebih besar dari 0';
    END IF;

    -- Perbarui stok produk
    UPDATE Produk
    SET stok = stok + p_jumlah
    WHERE id_produk = p_id_produk;

    -- Catat ke tabel Transaksi
    INSERT INTO Transaksi (tipe, perubahan, id_produk, id_pemasok, tanggal)
    VALUES ('Masuk', CONCAT('+', p_jumlah), p_id_produk, p_id_pemasok, CURRENT_TIMESTAMP);
END;
$$;


ALTER PROCEDURE public.tambah_stok(IN p_id_produk integer, IN p_jumlah integer, IN p_id_pemasok integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin (
    id_admin integer NOT NULL,
    nama character varying(100) NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL
);


ALTER TABLE public.admin OWNER TO postgres;

--
-- Name: admin_id_admin_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_id_admin_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_id_admin_seq OWNER TO postgres;

--
-- Name: admin_id_admin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_id_admin_seq OWNED BY public.admin.id_admin;


--
-- Name: pemasok; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pemasok (
    id_pemasok integer NOT NULL,
    username character varying(50) NOT NULL,
    kontak character varying(100)
);


ALTER TABLE public.pemasok OWNER TO postgres;

--
-- Name: pemasok_id_pemasok_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pemasok_id_pemasok_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pemasok_id_pemasok_seq OWNER TO postgres;

--
-- Name: pemasok_id_pemasok_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pemasok_id_pemasok_seq OWNED BY public.pemasok.id_pemasok;


--
-- Name: produk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produk (
    id_produk integer NOT NULL,
    nama_produk character varying(100) NOT NULL,
    kategori character varying(50) NOT NULL,
    stok integer NOT NULL,
    harga double precision NOT NULL,
    id_produk_ecommerce integer,
    CONSTRAINT produk_kategori_check CHECK (((kategori)::text = ANY ((ARRAY['Elektronik'::character varying, 'Pakaian'::character varying, 'Makanan'::character varying, 'Minuman'::character varying, 'Lainnya'::character varying])::text[])))
);


ALTER TABLE public.produk OWNER TO postgres;

--
-- Name: produk_id_produk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produk_id_produk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produk_id_produk_seq OWNER TO postgres;

--
-- Name: produk_id_produk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produk_id_produk_seq OWNED BY public.produk.id_produk;


--
-- Name: produkecommerce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produkecommerce (
    id_produk_ecommerce integer NOT NULL,
    nama_produk character varying(1000) NOT NULL,
    harga double precision NOT NULL
);


ALTER TABLE public.produkecommerce OWNER TO postgres;

--
-- Name: produkecommerce_id_produk_ecommerce_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produkecommerce_id_produk_ecommerce_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produkecommerce_id_produk_ecommerce_seq OWNER TO postgres;

--
-- Name: produkecommerce_id_produk_ecommerce_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produkecommerce_id_produk_ecommerce_seq OWNED BY public.produkecommerce.id_produk_ecommerce;


--
-- Name: toko; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.toko (
    id_toko integer NOT NULL,
    username character varying(50) NOT NULL,
    kontak character varying(100)
);


ALTER TABLE public.toko OWNER TO postgres;

--
-- Name: toko_id_toko_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.toko_id_toko_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.toko_id_toko_seq OWNER TO postgres;

--
-- Name: toko_id_toko_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.toko_id_toko_seq OWNED BY public.toko.id_toko;


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
-- Name: admin id_admin; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin ALTER COLUMN id_admin SET DEFAULT nextval('public.admin_id_admin_seq'::regclass);


--
-- Name: pemasok id_pemasok; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pemasok ALTER COLUMN id_pemasok SET DEFAULT nextval('public.pemasok_id_pemasok_seq'::regclass);


--
-- Name: produk id_produk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produk ALTER COLUMN id_produk SET DEFAULT nextval('public.produk_id_produk_seq'::regclass);


--
-- Name: produkecommerce id_produk_ecommerce; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkecommerce ALTER COLUMN id_produk_ecommerce SET DEFAULT nextval('public.produkecommerce_id_produk_ecommerce_seq'::regclass);


--
-- Name: toko id_toko; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.toko ALTER COLUMN id_toko SET DEFAULT nextval('public.toko_id_toko_seq'::regclass);


--
-- Name: transaksi id_transaksi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi ALTER COLUMN id_transaksi SET DEFAULT nextval('public.transaksi_id_transaksi_seq'::regclass);


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin (id_admin, nama, username, password) FROM stdin;
1	Admin Satu	admin1	password123
\.


--
-- Data for Name: pemasok; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pemasok (id_pemasok, username, kontak) FROM stdin;
1	pemasok1	081234567890
\.


--
-- Data for Name: produk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produk (id_produk, nama_produk, kategori, stok, harga, id_produk_ecommerce) FROM stdin;
1	Laptop	Elektronik	50	15000000	\N
2	Baju	Pakaian	100	200000	\N
3	Makanan Ringan	Makanan	200	10000	\N
4	Laptop	Elektronik	10	15000000	\N
5	Kulkas	Elektronik	10	5000000	\N
\.


--
-- Data for Name: produkecommerce; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produkecommerce (id_produk_ecommerce, nama_produk, harga) FROM stdin;
5	DETA-Sepeda Motor Yamaha Grand Filano Lux 2024	28699000
6	DETA-Sepeda Motor Yamaha Fazzio Lux 2024	23999000
7	Motor Yamaha Aerox 155 VVA Keyless & Standar- Bisa kirim Se Indonesia	37905000
8	yamaha jupiter z1  injeksi H kota	37905000
9	Jual Motor Yamaha Nmax 2019 2020 2021 - Siap Pakai - Tidak Ada Minus	37905000
10	JG GROUP - Yamaha Fazzio Lux Hybrid Connected	37905000
11	YAMAHA GRAND FILANO HYBRID 2024	37905000
12	Yamaha NMAX Turbo Standart Version	37905000
13	Yamaha Nmax "TURBO" Neo Version Jabodetabek	32356000
14	PYOPP FLEDGE - Tabi-ku Barefoot Shoes - Black	550420
15	SEPATU SNEAKERS ORTUSEIGHT BRISBANE - ASH GREY	509150
16	Sepatu Sneakers Wanita Puma Palermo Moda SurrealC Wns 39785402	143000
17	Sepatu Sneakers Cassual Pria Wanita Classic Low Black Size 	143000
18	Sepatu Casual LiNing Soft Go	49000
19	Sepatu Loafers Wanita Terbaru - Sepatu Docmart Wanita Korea	49000
20	CANIKOREA Youngji Sepatu Sneakers Wanita Casual Korean Shoes 9252	550420
21	Sepatu Compass Tribune White Blue	550420
22	Kanky Story Honjo - Sepatu Sneakers Casual Sport Sekolah Pria Dewasa	550420
23	PYOPP FLEDGE - Tabi-ku Barefoot Shoes - Black	550420
24	Kanky Klasik Story Kagayaku - Sepatu Sneakers Casual Sport Sekolah Pria Dewasa	509150
25	SEPATU SNEAKERS ORTUSEIGHT BRISBANE - ASH GREY	509150
26	Sepatu Sneakers Wanita Puma Palermo Moda SurrealC Wns 39785402	1699000
27	Sepatu Sneakers Cassual Pria Wanita Classic Low Black Size	143000
28	Sepatu Casual LiNing Soft Go	890000
29	Sepatu Loafers Wanita Terbaru - Sepatu Docmart Wanita Korea	49000
30	CANIKOREA Youngji Sepatu Sneakers Wanita Casual Korean Shoes 9252	135000
31	Sepatu Compass Tribune White Blue	568000
32	Kanky Story Honjo - Sepatu Sneakers Casual Sport Sekolah Pria Dewasa	318800
33	PYOPP FLEDGE - Tabi-ku Barefoot Shoes - Black	550420
34	Kanky Klasik Story Kagayaku - Sepatu Sneakers Casual Sport Sekolah Pria Dewasa	388800
35	SEPATU SNEAKERS ORTUSEIGHT BRISBANE - ASH GREY	509150
\.


--
-- Data for Name: toko; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.toko (id_toko, username, kontak) FROM stdin;
1	toko1	081234567893
2	toko2	081234567894
3	toko3	081234567895
\.


--
-- Data for Name: transaksi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaksi (id_transaksi, tanggal, tipe, perubahan, id_produk, id_pemasok, id_toko, id_admin) FROM stdin;
1	2024-12-09 17:09:11.493424	Produk Baru	Tambah produk: Laptop	\N	\N	\N	1
2	2024-12-09 17:09:19.480311	Produk Baru	Tambah produk: Kulkas	\N	\N	\N	1
\.


--
-- Name: admin_id_admin_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_id_admin_seq', 1, true);


--
-- Name: pemasok_id_pemasok_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pemasok_id_pemasok_seq', 1, true);


--
-- Name: produk_id_produk_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produk_id_produk_seq', 5, true);


--
-- Name: produkecommerce_id_produk_ecommerce_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produkecommerce_id_produk_ecommerce_seq', 110, true);


--
-- Name: toko_id_toko_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.toko_id_toko_seq', 3, true);


--
-- Name: transaksi_id_transaksi_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transaksi_id_transaksi_seq', 2, true);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id_admin);


--
-- Name: admin admin_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_username_key UNIQUE (username);


--
-- Name: pemasok pemasok_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pemasok
    ADD CONSTRAINT pemasok_pkey PRIMARY KEY (id_pemasok);


--
-- Name: pemasok pemasok_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pemasok
    ADD CONSTRAINT pemasok_username_key UNIQUE (username);


--
-- Name: produk produk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produk
    ADD CONSTRAINT produk_pkey PRIMARY KEY (id_produk);


--
-- Name: produkecommerce produkecommerce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produkecommerce
    ADD CONSTRAINT produkecommerce_pkey PRIMARY KEY (id_produk_ecommerce);


--
-- Name: toko toko_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.toko
    ADD CONSTRAINT toko_pkey PRIMARY KEY (id_toko);


--
-- Name: toko toko_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.toko
    ADD CONSTRAINT toko_username_key UNIQUE (username);


--
-- Name: transaksi transaksi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_pkey PRIMARY KEY (id_transaksi);


--
-- Name: produk produk_id_produk_ecommerce_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produk
    ADD CONSTRAINT produk_id_produk_ecommerce_fkey FOREIGN KEY (id_produk_ecommerce) REFERENCES public.produkecommerce(id_produk_ecommerce) ON DELETE SET NULL;


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
-- Name: PROCEDURE tambah_produk(IN p_nama_produk character varying, IN p_kategori character varying, IN p_harga double precision, IN p_stok integer, IN p_id_admin integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.tambah_produk(IN p_nama_produk character varying, IN p_kategori character varying, IN p_harga double precision, IN p_stok integer, IN p_id_admin integer) TO admin_role;


--
-- Name: PROCEDURE tambah_stok(IN p_id_produk integer, IN p_jumlah integer, IN p_id_pemasok integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.tambah_stok(IN p_id_produk integer, IN p_jumlah integer, IN p_id_pemasok integer) TO pemasok_role;


--
-- Name: TABLE produk; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.produk TO admin_role;


--
-- Name: SEQUENCE produk_id_produk_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.produk_id_produk_seq TO admin_role;


--
-- Name: TABLE transaksi; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.transaksi TO admin_role;


--
-- Name: SEQUENCE transaksi_id_transaksi_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.transaksi_id_transaksi_seq TO admin_role;


--
-- PostgreSQL database dump complete
--

