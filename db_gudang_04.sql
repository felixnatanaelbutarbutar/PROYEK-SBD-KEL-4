--============ KELOMPOK 04 SISTEM BASIS DATA ============--
--======== SISTEM PENGELOLAAN INVENTARIS GUDANG ========--

CREATE DATABASE db_gudang_04

--=== CREATE TABLE===--

CREATE TABLE Gudang (
    idGudang SERIAL PRIMARY KEY,
    namaGudang VARCHAR(100) NOT NULL,
    lokasi VARCHAR(255) NOT NULL,
    kapasitas INT NOT NULL
);

CREATE TABLE Pemasok (
    idPemasok SERIAL PRIMARY KEY,
    namaPemasok VARCHAR(100) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    telepon VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL
);

CREATE TABLE Produk (
    idProduk SERIAL PRIMARY KEY,
    idPemasok INT NOT NULL,
    idGudang INT NOT NULL,
    namaProduk VARCHAR(100) NOT NULL,
    deskripsi VARCHAR(255),
    kategori VARCHAR(50),
    harga DECIMAL(10, 2) NOT NULL,
    stok INT NOT NULL,
    tanggalMasuk DATE NOT NULL,
    tanggalKadaluarsa DATE NOT NULL,
    CONSTRAINT fk_pemasok FOREIGN KEY (idPemasok) REFERENCES Pemasok(idPemasok),
    CONSTRAINT fk_gudang FOREIGN KEY (idGudang) REFERENCES Gudang(idGudang)
);

CREATE TABLE Transaksi (
    idTransaksi SERIAL PRIMARY KEY,
    idProduk INT NOT NULL,
    idGudang INT NOT NULL,
    jumlah INT NOT NULL,
    tanggalTransaksi DATE NOT NULL,
    jenisTransaksi VARCHAR(50) NOT NULL,
    CONSTRAINT fk_produk FOREIGN KEY (idProduk) REFERENCES Produk(idProduk),
    CONSTRAINT fk_gudang_transaksi FOREIGN KEY (idGudang) REFERENCES Gudang(idGudang)
);


--=== DUMMY DATA===--

INSERT INTO Pemasok (namaPemasok, alamat, telepon, email)
VALUES 
('Pemasok A', 'Jalan Mawar No. 1', '081234567890', 'pemasoka@gmail.com'),
('Pemasok B', 'Jalan Melati No. 2', '081234567891', 'pemasokb@gmail.com'),
('Pemasok C', 'Jalan Anggrek No. 3', '081234567892', 'pemasokc@gmail.com'),
('Pemasok D', 'Jalan Kenanga No. 4', '081234567893', 'pemasokd@gmail.com'),
('Pemasok E', 'Jalan Dahlia No. 5', '081234567894', 'pemasoke@gmail.com');

INSERT INTO Gudang (namaGudang, lokasi, kapasitas)
VALUES 
('Gudang Utama', 'Sitolu Ama', 10000);

INSERT INTO Produk (idPemasok, idGudang, namaProduk, deskripsi, kategori, harga, stok, tanggalMasuk, tanggalKadaluarsa)
VALUES 
(1, 1, 'Cokelat', 'Cokelat batangan untuk membuat kue atau makanan ringan', 'Bahan Makanan', 15000.00, 100, '2024-12-01', '2025-12-01'),
(2, 1, 'Tepung Terigu', 'Tepung terigu serbaguna untuk membuat roti dan kue', 'Bahan Makanan', 12000.00, 200, '2024-12-02', '2025-12-02'),
(3, 1, 'Gula Pasir', 'Gula pasir halus untuk masakan dan minuman', 'Bahan Makanan', 10000.00, 150, '2024-12-03', '2025-12-03'),
(4, 1, 'Minyak Goreng', 'Minyak goreng kualitas tinggi untuk memasak', 'Bahan Makanan', 30000.00, 50, '2024-12-04', '2025-12-04'),
(5, 1, 'Susu Bubuk', 'Susu bubuk full cream untuk masakan atau minuman', 'Bahan Makanan', 50000.00, 75, '2024-12-05', '2025-12-05');

INSERT INTO Transaksi (idProduk, idGudang, jumlah, tanggalTransaksi, jenisTransaksi)
VALUES 
(1, 1, 10, '2024-12-01', 'Penjualan'),
(2, 1, 15, '2024-12-02', 'Pembelian'),
(3, 1, 5, '2024-12-03', 'Penjualan'),
(4, 1, 8, '2024-12-04', 'Pembelian'),
(5, 1, 12, '2024-12-05', 'Penjualan');

--===Fitur 1: Pemantauan Stok Barang
-- Membuat View untuk memantau stok barang dan memberikan peringatan jika stok habis:
CREATE VIEW StokGudang AS
SELECT 
    g.namaGudang, 
    p.namaProduk, 
    p.stok,
    p.tanggalKadaluarsa,
    CASE 
        WHEN p.stok = 0 THEN 'Stok Habis'
        WHEN p.stok < 10 THEN 'Stok Hampir Habis'
        ELSE 'Stok Cukup'
    END AS statusStok
FROM Produk p
JOIN Gudang g ON p.idGudang = g.idGudang;

-- Melihat data stok
SELECT * FROM StokGudang;

CREATE VIEW PemantauanStok AS
SELECT 
    p.namaProduk, 
    p.stok, 
    p.tanggalKadaluarsa, 
    pm.namaPemasok, 
    g.namaGudang
FROM Produk p
JOIN Pemasok pm ON p.idPemasok = pm.idPemasok
JOIN Gudang g ON p.idGudang = g.idGudang;

SELECT * FROM PemantauanStok;


--=== Fitur 2 : Stored Procedure
-- Membuat prosedur untuk menambahkan stok produk:
CREATE OR REPLACE FUNCTION TambahStok(
    prodID INT, 
    tambahanStok INT
) RETURNS VOID AS $$
DECLARE
    rows_affected INT;
BEGIN
    -- Update stok produk dan simpan jumlah baris yang diperbarui
    UPDATE Produk
    SET stok = stok + tambahanStok
    WHERE idProduk = prodID
    RETURNING idProduk INTO rows_affected;

    -- Periksa apakah ada baris yang diperbarui
    IF NOT FOUND THEN
        RAISE NOTICE 'No rows updated in Produk. Check prodID: %', prodID;
    END IF;

    -- Catat transaksi
    INSERT INTO Transaksi (idProduk, idGudang, jumlah, tanggalTransaksi, jenisTransaksi)
    VALUES (
        prodID, 
        (SELECT idGudang FROM Produk WHERE idProduk = prodID), 
        tambahanStok, 
        CURRENT_DATE, 
        'Pembelian'
    );
END;
$$ LANGUAGE plpgsql;


SELECT * FROM Produk;
SELECT TambahStok(1, 50);

SELECT * FROM Transaksi;


CREATE OR REPLACE FUNCTION cegah_stok_negatif()
RETURNS TRIGGER AS $$
BEGIN
    -- Jika stok menjadi negatif, hentikan operasi dan beri pesan error
    IF NEW.stok < 0 THEN
        RAISE EXCEPTION 'Stok tidak boleh negatif.';
    END IF;

    -- Lanjutkan operasi jika stok valid
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER CegahStokNegatif
BEFORE UPDATE ON Produk
FOR EACH ROW
EXECUTE FUNCTION cegah_stok_negatif();

-- Uji kasus stok negatif
UPDATE Produk
SET stok = stok - 200
WHERE idProduk = 1; -- Misalnya stok awal kurang dari 200


