--============ KELOMPOK 04 SISTEM BASIS DATA ============--
--======== SISTEM PENGELOLAAN INVENTARIS GUDANG ========--

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
    nama_produk VARCHAR(100) NOT NULL,
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

--=== 02. INSERT DUMMY DATA ===--
-- Insert Admin
INSERT INTO Admin (nama, username, password)
VALUES
    ('Admin Satu', 'admin1', 'password123');


-- Insert Pemasok
INSERT INTO Pemasok (username, kontak)
VALUES
    ('pemasok1', '081234567890');


-- Insert Toko
INSERT INTO Toko (username, kontak)
VALUES
    ('toko1', '081234567893'),
    ('toko2', '081234567894'),
    ('toko3', '081234567895');

INSERT INTO Produk (nama_produk, kategori, stok, harga, id_produk_ecommerce)
VALUES
    ('Laptop', 'Elektronik', 50, 15000000, NULL),
    ('Baju', 'Pakaian', 100, 200000, NULL),
    ('Makanan Ringan', 'Makanan', 200, 10000, NULL);


--=== 2. FITUR CATAT TRANSAKSI OTOMATIS BERDASARKAN ROLE() ===--
-- A. Fungsi untuk Menambah Produk ke Tabel Produk
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

    -- Tambahkan produk ke tabel Produk
    INSERT INTO Produk (nama_produk, kategori, harga, stok)
    VALUES (p_nama_produk, p_kategori, p_harga, p_stok);

    -- Catat transaksi untuk produk baru
    INSERT INTO Transaksi (tipe, perubahan, id_admin, tanggal)
    VALUES ('Produk Baru', CONCAT('Tambah produk: ', p_nama_produk), p_id_admin, CURRENT_TIMESTAMP);
END;
$$;

-- Hak Akses
GRANT EXECUTE ON PROCEDURE tambah_produk TO admin_role; -- Berikan akses hanya ke role admin

-- Test
SET ROLE admin_role

CALL tambah_produk('Laptop', 'Elektronik', 15000000, 10, 1); 

CALL tambah_produk('Kulkas', 'Elektronik', 5000000, 10, 1);

RESET ROLE

-- Memberikan hak akses untuk sequence produk_id_produk_seq
GRANT USAGE, SELECT ON SEQUENCE produk_id_produk_seq TO admin_role;
-- Memberikan hak akses untuk sequence transaksi_id_transaksi_seq
GRANT USAGE, SELECT ON SEQUENCE transaksi_id_transaksi_seq TO admin_role;
-- Memberikan hak akses untuk melihat tabel transaksi
GRANT ALL ON TABLE Transaksi TO admin_role;
-- Memberikan hak akses untuk melihat tabel Produk
GRANT ALL ON TABLE Produk TO admin_role;

SELECT * FROM Transaksi;

SELECT * FROM Produk;

-- B. Fungsi untuk Menambah Stok oleh Pemasok
CREATE OR REPLACE PROCEDURE tambah_stok(
    p_id_produk INT,
    p_jumlah INT,
    p_id_pemasok INT
)
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

-- Hak Akses
GRANT EXECUTE ON PROCEDURE tambah_stok TO pemasok_role; -- Berikan akses hanya ke role pemasok

-- Test
SET ROLE pemasok_role;

CALL tambah_stok(1, 1, 1);

RESET ROLE

-- Memberikan hak akses untuk sequence produk_id_produk_seq
GRANT USAGE, SELECT ON SEQUENCE produk_id_produk_seq TO pemasok_role;
-- Memberikan hak akses untuk sequence transaksi_id_transaksi_seq
GRANT USAGE, SELECT ON SEQUENCE transaksi_id_transaksi_seq TO pemasok_role;
-- Memberikan hak akses untuk melihat tabel transaksi
GRANT ALL ON TABLE Transaksi TO pemasok_role;
-- Memberikan hak akses untuk melihat tabel Produk
GRANT SELECT, UPDATE ON TABLE Produk TO pemasok_role;

SELECT * FROM Transaksi;

SELECT * FROM Produk;

-- C. Fungsi untuk Mengurangi Stok oleh Toko
CREATE OR REPLACE PROCEDURE kurangi_stok(
    p_id_produk INT,
    p_jumlah INT,
    p_id_toko INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    stok_sekarang INT;
BEGIN
    -- Validasi jumlah stok
    IF p_jumlah <= 0 THEN
        RAISE EXCEPTION 'Jumlah stok yang dikurangi harus lebih besar dari 0';
    END IF;

    -- Ambil stok produk saat ini
    SELECT stok 
    INTO stok_sekarang
    FROM Produk
    WHERE id_produk = p_id_produk;

    -- Periksa apakah stok mencukupi dan tidak kurang dari batas minimum (10)
    IF stok_sekarang < p_jumlah THEN
        RAISE EXCEPTION 'Stok tidak mencukupi untuk pengurangan.';
    ELSIF stok_sekarang - p_jumlah <= 10 THEN
        RAISE EXCEPTION 'Stok tidak boleh berkurang karena akan melewati batas minimum (10).';
    END IF;

    -- Perbarui stok produk
    UPDATE Produk
    SET stok = stok - p_jumlah
    WHERE id_produk = p_id_produk;

    -- Catat ke tabel Transaksi
    INSERT INTO Transaksi (tipe, perubahan, id_produk, id_toko, tanggal)
    VALUES ('Keluar', CONCAT('-', p_jumlah), p_id_produk, p_id_toko, CURRENT_TIMESTAMP);

    -- Berikan notifikasi sukses
    RAISE NOTICE 'Transaksi berhasil: Produk % telah dikurangi sebanyak % unit.', p_id_produk, p_jumlah;

END;
$$;

-- Hak akses
GRANT EXECUTE ON PROCEDURE kurangi_stok TO toko_role; -- Berikan akses hanya ke role toko

-- Test Prosedur
SET ROLE toko_role;

-- Misalnya: Coba kurangi stok
CALL kurangi_stok(3, 5, 1);

RESET ROLE;

-- Transaksi Mengurangi stok, bila produk <= 10 maka tidak bisa
BEGIN;
CALL kurangi_stok(1, 5, 1); -- bisa
COMMIT;

BEGIN;
CALL kurangi_stok(4, 15, 1); -- tidak bisa
ROLLBACK;

-- Periksa hasil
SELECT * FROM Transaksi;
SELECT * FROM Produk;

-- Test
SET ROLE toko_role;

RESET ROLE

-- Memberikan hak akses untuk sequence produk_id_produk_seq
GRANT USAGE, SELECT ON SEQUENCE produk_id_produk_seq TO toko_role;
-- Memberikan hak akses untuk sequence transaksi_id_transaksi_seq
GRANT USAGE, SELECT ON SEQUENCE transaksi_id_transaksi_seq TO toko_role;
-- Memberikan hak akses untuk melihat tabel transaksi
GRANT SELECT, UPDATE ON TABLE Transaksi TO toko_role;
-- Memberikan hak akses untuk melihat tabel Produk
GRANT SELECT, UPDATE ON TABLE Produk TO toko_role;

-- d. Pemantau Stok
-- Prosedur untuk memantau stok
CREATE OR REPLACE PROCEDURE pantau_stok()
LANGUAGE plpgsql
AS $$
DECLARE
    produk RECORD;
BEGIN
    -- Loop melalui semua produk
    FOR produk IN
        SELECT id_produk, nama_produk, stok
        FROM Produk
    LOOP
        -- Jika stok habis
        IF produk.stok = 0 THEN
            RAISE NOTICE 'PERINGATAN: Stok produk "% (ID: %)" habis!', produk.nama_produk, produk.id_produk;
        -- Jika stok mendekati habis
        ELSIF produk.stok <= 10 THEN
            RAISE NOTICE 'PERINGATAN: Stok produk "% (ID: %)" hanya tersisa % unit.', produk.nama_produk, produk.id_produk, produk.stok;
        END IF;
    END LOOP;
END;
$$;

-- Test
CALL pantau_stok();

-- e.View untuk melihat log barang hampir habis
CREATE OR REPLACE VIEW view_log_peringatan AS
SELECT 
    p.id_produk,
    p.nama_produk,
    p.stok,
    CASE
        WHEN p.stok = 0 THEN 'HABIS'
        WHEN p.stok <= 10 THEN 'MENDEKATI HABIS'
        ELSE 'AMAN'
    END AS status,
    CURRENT_TIMESTAMP AS waktu_pemeriksaan
FROM Produk p
WHERE p.stok <= 10;

SELECT * FROM view_log_peringatan;


-- e. trigger untuk cegah stok negatif
-- Trigger untuk mencegah stok negatif
CREATE OR REPLACE FUNCTION cek_stok_negatif()
RETURNS TRIGGER AS $$
DECLARE
    v_id_produk INT;
    v_valid_produk BOOLEAN := FALSE;
    c_produk CURSOR FOR SELECT id_produk FROM Produk;
BEGIN
    -- Cek apakah id_produk yang baru ada dalam tabel Produk
    OPEN c_produk;
    LOOP
        FETCH c_produk INTO v_id_produk;
        EXIT WHEN NOT FOUND;

        -- Jika ditemukan id_produk yang sesuai
        IF v_id_produk = NEW.id_produk THEN
            v_valid_produk := TRUE;
            EXIT;
        END IF;
    END LOOP;
    CLOSE c_produk;

    -- Jika produk tidak ditemukan
    IF NOT v_valid_produk THEN
        RAISE EXCEPTION 'Produk dengan ID % tidak ditemukan.', NEW.id_produk;
    END IF;

    -- Pengecekan jika stok akan menjadi negatif
    IF NEW.stok < 0 THEN
        -- Catat ke tabel Transaksi bahwa perubahan stok dibatalkan
        INSERT INTO Transaksi (tipe, perubahan, id_produk, tanggal)
        VALUES ('Ditolak', 'Pengurangan stok dibatalkan: Stok negatif', OLD.id_produk, CURRENT_TIMESTAMP);

        -- Batalkan perubahan dan munculkan exception
        RAISE EXCEPTION 'Pengurangan stok tidak dapat dilakukan karena stok akan menjadi negatif.';
    END IF;

    -- Jika stok valid, lanjutkan proses
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cek_stok_negatif
BEFORE UPDATE ON Produk
FOR EACH ROW
WHEN (OLD.stok <> NEW.stok)
EXECUTE FUNCTION cek_stok_negatif();

UPDATE Produk
SET stok = stok - 5
WHERE id_produk = 4;

SELECT * FROM Transaksi;

SELECT * FROM Produk;

--=== 5. VIEW UNTUK MENYEDERHANAKAN ANALISIS ===--

-- A. Laporan Transaksi Lengkap
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

SELECT * FROM LaporanTransaksi;

-- B. Produk oleh Pemasok
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

SELECT * FROM view_produk_pemasok;

-- C. Pendapatan Per Toko
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

SELECT * FROM view_pendapatan_toko;




