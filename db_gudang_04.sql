--============ KELOMPOK 04 SISTEM BASIS DATA ============--
--======== SISTEM PENGELOLAAN INVENTARIS GUDANG ========--

--=== 1. CREATE DATABASE ===--
-- Tabel Users
CREATE TABLE Users (
    idUser SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Pemasok', 'Toko')),
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Tabel Produk
CREATE TABLE Produk (
    idProduk SERIAL PRIMARY KEY,
    namaProduk VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    harga FLOAT NOT NULL,
    jumlahStok INT NOT NULL,
    kategori VARCHAR(20) NOT NULL CHECK (kategori IN ('Elektronik', 'Pakaian', 'Makanan', 'Minuman', 'Lainnya')),
    tanggalMasuk DATE NOT NULL,
    tanggalKedaluwarsa DATE,
    idGudang INT NOT NULL,
    FOREIGN KEY (idGudang) REFERENCES Gudang(idGudang)
);

-- Tabel Gudang
CREATE TABLE Gudang (
    idGudang SERIAL PRIMARY KEY,
    namaGudang VARCHAR(100) NOT NULL,
    kapasitas INT NOT NULL,
    lokasi VARCHAR(255) NOT NULL
);

-- Tabel Transaksi
CREATE TABLE Transaksi (
    idTransaksi SERIAL PRIMARY KEY,
    idUser INT NOT NULL,
    idProduk INT NOT NULL,
    jenisTransaksi VARCHAR(50) NOT NULL,
    tanggalTransaksi DATE NOT NULL,
    jumlah INT NOT NULL,
    FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE,
    FOREIGN KEY (idProduk) REFERENCES Produk(idProduk) ON DELETE CASCADE
);

-- Tabel ProdukEcommerce
CREATE TABLE ProdukEcommerce (
    idEcommerceProduk SERIAL PRIMARY KEY,
    idProduk INT NOT NULL,
    namaProduk VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    harga FLOAT NOT NULL,
    jumlahStok INT NOT NULL,
    kategori VARCHAR(20) NOT NULL CHECK (kategori IN ('Elektronik', 'Pakaian', 'Makanan', 'Minuman', 'Lainnya')),
    tanggalMasuk DATE NOT NULL,
    tanggalKedaluwarsa DATE,
    sumberECommerce VARCHAR(100) NOT NULL,
    FOREIGN KEY (idProduk) REFERENCES Produk(idProduk) ON DELETE CASCADE
);

--=== 02. INSERT DUMMY DATA ===--
INSERT INTO Users (role, username, password)
VALUES 
    ('Admin', 'admin@gmail.com', 'admin123'),
	('Toko', 'toko@gmail.com', 'toko123'),
    ('Pemasok', 'pemasok@gmail.com', 'pemasok123');

INSERT INTO Gudang (namaGudang, kapasitas, lokasi)
VALUES
    ('Gudang Utama', 1000000, 'Sidua Ama');

INSERT INTO Produk (namaProduk, deskripsi, harga, jumlahStok, kategori, tanggalMasuk, tanggalKedaluwarsa, idGudang)
VALUES
    ('Laptop Thinkpad X1 Carbon Intel Ultra 7 165U 1TB', 'Laptop programing dengan spesifikasi tinggi', 36000000, 50, 'Elektronik', '2024-01-01', NULL, 1),
    ('Kemeja Aan ', 'Kemeja formal untuk jadi ganteng', 200000, 1000, 'Pakaian', '2024-02-01', NULL, 1),
    ('Rengginang', 'Kerupuk teman makan', 5000, 500, 'Makanan', '2024-03-01', '2024-09-01', 1);

select * from Gudang;
SELECT * FROM Users
select * from Produk;




