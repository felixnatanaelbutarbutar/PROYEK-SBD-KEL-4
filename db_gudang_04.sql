--============ KELOMPOK 04 SISTEM BASIS DATA ============
--======== SISTEM PENGELOLAAN INVENTARIS GUDANG =========

--=== 1. CREATE DATABASE ===--

-- Tabel Admin
CREATE TABLE Admin (
    id_admin SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Tabel Pemasok
CREATE TABLE Pemasok (
    id_pemasok SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    kontak VARCHAR(100)
);

-- Tabel Toko
CREATE TABLE Toko (
    id_toko SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    kontak VARCHAR(100)
);

-- Tabel ProdukEcommerce
CREATE TABLE ProdukEcommerce (
    id_produk_ecommerce SERIAL PRIMARY KEY,
    nama_produk VARCHAR(1000) NOT NULL,
    harga DOUBLE PRECISION NOT NULL
);

-- Tabel Produk
CREATE TABLE Produk (
    id_produk SERIAL PRIMARY KEY,
    nama_produk VARCHAR(100) NOT NULL,
    kategori VARCHAR(50) NOT NULL CHECK (kategori IN ('Elektronik', 'Pakaian', 'Makanan', 'Minuman', 'Lainnya')),
    stok INT NOT NULL,
    harga DOUBLE PRECISION NOT NULL,
    id_produk_ecommerce INT,
    FOREIGN KEY (id_produk_ecommerce) REFERENCES ProdukEcommerce (id_produk_ecommerce) ON DELETE SET NULL
);

-- Tabel Transaksi
CREATE TABLE Transaksi (
    id_transaksi SERIAL PRIMARY KEY,
    tanggal TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipe VARCHAR(20) NOT NULL CHECK (tipe IN ('Masuk', 'Keluar', 'Produk Baru')),
    perubahan TEXT,
    id_produk INT,
    id_pemasok INT,
    id_toko INT,
    id_admin INT,
    FOREIGN KEY (id_produk) REFERENCES Produk (id_produk) ON DELETE SET NULL,
    FOREIGN KEY (id_pemasok) REFERENCES Pemasok (id_pemasok) ON DELETE SET NULL,
    FOREIGN KEY (id_toko) REFERENCES Toko (id_toko) ON DELETE SET NULL,
    FOREIGN KEY (id_admin) REFERENCES Admin (id_admin) ON DELETE SET NULL
);

--=== 2. INSERT DUMMY DATA ===--

-- Insert Admin
INSERT INTO Admin (nama, username, password) VALUES
('Admin Satu', 'admin1', 'password123');

-- Insert Pemasok
INSERT INTO Pemasok (username, kontak) VALUES
('pemasok1', '081234567890');

-- Insert Toko
INSERT INTO Toko (username, kontak) VALUES
('toko1', '081234567893'),
('toko2', '081234567894'),
('toko3', '081234567895');

-- Insert Produk
INSERT INTO Produk (nama_produk, kategori, stok, harga, id_produk_ecommerce) VALUES
('Laptop', 'Elektronik', 50, 15000000, NULL),
('Baju', 'Pakaian', 100, 200000, NULL),
('Makanan Ringan', 'Makanan', 200, 10000, NULL);

--=== 3. FITUR CATAT TRANSAKSI OTOMATIS BERDASARKAN ROLE ===--

-- A. Fungsi Menambah Produk
CREATE OR REPLACE PROCEDURE tambah_produk(
    p_nama_produk VARCHAR(100),
    p_kategori VARCHAR(50),
    p_harga DOUBLE PRECISION,
    p_stok INT,
    p_id_admin INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validasi kategori
    IF NOT (p_kategori IN ('Elektronik', 'Pakaian', 'Makanan', 'Minuman', 'Lainnya')) THEN
        RAISE EXCEPTION 'Kategori tidak valid.';
    END IF;

    -- Tambah produk
    INSERT INTO Produk (nama_produk, kategori, harga, stok)
    VALUES (p_nama_produk, p_kategori, p_harga, p_stok);

    -- Catat transaksi
    INSERT INTO Transaksi (tipe, perubahan, id_admin, tanggal)
    VALUES ('Produk Baru', CONCAT('Tambah produk: ', p_nama_produk), p_id_admin, CURRENT_TIMESTAMP);
END;
$$;

GRANT EXECUTE ON PROCEDURE tambah_produk TO admin_role;

-- B. Fungsi Menambah Stok
CREATE OR REPLACE PROCEDURE tambah_stok(
    p_id_produk INT,
    p_jumlah INT,
    p_id_pemasok INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_jumlah <= 0 THEN
        RAISE EXCEPTION 'Jumlah stok yang ditambahkan harus lebih besar dari 0';
    END IF;

    UPDATE Produk
    SET stok = stok + p_jumlah
    WHERE id_produk = p_id_produk;

    INSERT INTO Transaksi (tipe, perubahan, id_produk, id_pemasok, tanggal)
    VALUES ('Masuk', CONCAT('+', p_jumlah), p_id_produk, p_id_pemasok, CURRENT_TIMESTAMP);
END;
$$;

GRANT EXECUTE ON PROCEDURE tambah_stok TO pemasok_role;

-- C. Fungsi Mengurangi Stok
CREATE OR REPLACE PROCEDURE kurangi_stok(
    p_id_produk INT,
    p_jumlah INT,
    p_id_toko INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_jumlah <= 0 THEN
        RAISE EXCEPTION 'Jumlah stok yang dikurangi harus lebih besar dari 0';
    END IF;

    IF (SELECT stok FROM Produk WHERE id_produk = p_id_produk) < p_jumlah THEN
        RAISE EXCEPTION 'Stok tidak mencukupi.';
    END IF;

    UPDATE Produk
    SET stok = stok - p_jumlah
    WHERE id_produk = p_id_produk;

    INSERT INTO Transaksi (tipe, perubahan, id_produk, id_toko, tanggal)
    VALUES ('Keluar', CONCAT('-', p_jumlah), p_id_produk, p_id_toko, CURRENT_TIMESTAMP);
END;
$$;

GRANT EXECUTE ON PROCEDURE kurangi_stok TO toko_role;

--=== 4. PENGATURAN ROLE DAN HAK AKSES ===--

-- Role Admin
CREATE ROLE admin_role;
-- Role Pemasok
CREATE ROLE pemasok_role;
-- Role Toko
CREATE ROLE toko_role;

-- Grant role ke pengguna
GRANT admin_role TO admin_user;
GRANT pemasok_role TO pemasok_user;
GRANT toko_role TO toko_user;

-- Batasi akses langsung
REVOKE ALL ON TABLE Produk FROM PUBLIC;
GRANT INSERT, UPDATE ON TABLE Produk TO admin_role, pemasok_role;

REVOKE ALL ON TABLE Transaksi FROM PUBLIC;
GRANT INSERT ON TABLE Transaksi TO admin_role, pemasok_role, toko_role;

--=== 5. VIEW UNTUK MENYEDERHANAKAN ANALISIS ===--

-- A. Produk Hampir Habis
CREATE OR REPLACE VIEW view_produk_hampir_habis AS
SELECT 
    id_produk,
    nama_produk,
    kategori,
    stok
FROM Produk
WHERE stok <= 10;

-- B. Laporan Transaksi Lengkap
CREATE OR REPLACE VIEW LaporanTransaksi AS
SELECT
    t.id_transaksi,
    t.tanggal,
    t.tipe,
    t.perubahan,
    p.nama_produk,
    adm.nama AS nama_admin,
    pm.username AS nama_pemasok,
    tk.username AS nama_toko
FROM Transaksi t
LEFT JOIN Produk p ON t.id_produk = p.id_produk
LEFT JOIN Admin adm ON t.id_admin = adm.id_admin
LEFT JOIN Pemasok pm ON t.id_pemasok = pm.id_pemasok
LEFT JOIN Toko tk ON t.id_toko = tk.id_toko;

-- C. Produk oleh Pemasok
CREATE OR REPLACE VIEW view_produk_pemasok AS
SELECT 
    p.id_produk,
    p.nama_produk,
    p.kategori,
    p.stok,
    p.harga,
    t.id_pemasok
FROM 
    Produk p
JOIN Transaksi t ON p.id_produk = t.id_produk
WHERE t.tipe = 'Masuk';

-- D. Pendapatan Per Toko
CREATE OR REPLACE VIEW view_pendapatan_toko AS
SELECT 
    t.id_toko,
    tk.username AS nama_toko,
    SUM(p.harga * CAST(SPLIT_PART(t.perubahan, '-', 2) AS INT)) AS total_pendapatan
FROM 
    Transaksi t
JOIN Toko tk ON t.id_toko = tk.id_toko
JOIN Produk p ON t.id_produk = p.id_produk
WHERE t.tipe = 'Keluar'
GROUP BY t.id_toko, tk.username;
