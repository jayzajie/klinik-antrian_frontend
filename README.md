# Klinik Frontend

Aplikasi mobile buat sistem antrian klinik yang dibuat pake Flutter. Jadi ada 2 role nih, pasien sama admin. Pasien bisa ambil antrian, admin bisa manage semuanya.

<img width="3840" height="2160" alt="Klinik-Antrian" src="https://github.com/user-attachments/assets/e6273566-e194-4fa9-bd24-8f80dc454e03" />

ini repo buat backend : https://github.com/jayzajie/klinik-antrian_backend

## Tech Stack

### Core Framework
**Flutter 3.10+** - Framework Google buat bikin cross-platform mobile app. Satu codebase jalan di Android sama iOS. Performanya native-like karena compile langsung ke machine code.

### Programming Language
**Dart** - Bahasa pemrograman yang dipake Flutter. Syntax-nya mirip JavaScript tapi strongly typed. Punya fitur modern kayak null safety, async/await, sama hot reload.

### State Management
**Provider 6.1+** - Package buat manage state di Flutter. Dipilih karena simple, performant, sama officially recommended sama Flutter team. Lebih ringan dari Bloc atau Riverpod.

### HTTP Client
**http 1.2+** - Package buat komunikasi sama REST API. Handle semua HTTP request (GET, POST, PUT, DELETE) dengan clean API.

### Local Storage
**SharedPreferences 2.2+** - Buat simpen data lokal kayak auth token. Data-nya persistent meskipun app ditutup.

### Date Formatting
**intl 0.19+** - Package buat format tanggal, waktu, sama currency. Support internationalization kalo mau multi-language.

### Push Notifications
**Firebase Cloud Messaging 15.1+** - Buat nerima push notification dari backend. Jalan di background maupun foreground.

**Firebase Core 3.8+** - Core Firebase SDK yang dibutuhin buat FCM.

### PDF Generation
**pdf 3.11+** - Library buat generate PDF langsung di Flutter. Dipake buat export laporan.

**printing 5.13+** - Package buat preview sama print PDF. Bisa langsung print atau share PDF.

**path_provider 2.1+** - Buat dapetin path directory di device buat simpen file PDF.

## Gimana Cara Kerjanya

Aplikasi ini pake Provider buat state management, jadi data flow-nya rapi. Komunikasi sama backend pake HTTP client biasa. Struktur foldernya udah dipisah-pisah biar gampang maintain: screens, services, providers, models, config semua terpisah.

## Fitur Buat Pasien

### Daftar dan Login
Pasien bisa daftar sendiri, isi data diri lengkap kayak nama, email, nomor HP, alamat. Abis daftar langsung bisa login dan pake aplikasinya. Session-nya disimpen pake token di local storage, jadi ga perlu login terus-terusan.

### Ambil Nomor Antrian
Cara kerjanya gini: pilih poli yang mau dikunjungi, liat jadwal dokternya, terus ambil nomor. Nah yang keren, sistem otomatis ngitung estimasi waktu tunggu berdasarkan berapa banyak orang yang lagi ngantri dan rata-rata waktu pelayanannya.

### Pantau Status Antrian
Pasien bisa liat status antriannya real-time. Nanti bakal dapet notifikasi push kalo udah dipanggil. Status-nya jelas banget: lagi nunggu, udah dipanggil, atau udah selesai.

### Riwayat Kunjungan
Semua history antrian kesimpen, bisa diliat kapan aja. Ada info lengkap kayak tanggal kunjungan, poli apa, dokter siapa, sampe catatan diagnosis kalo ada.

### Batal Antrian
Pasien bisa batal sendiri, tapi ada syaratnya: minimal H-1 sebelum tanggal antrian. Jadi ga bisa batal di hari yang sama, biar ga bikin slot kosong mendadak.

### Update Profil
Bisa update info pribadi kayak nomor HP sama alamat. Data-nya sync sama backend, jadi login dari HP mana aja tetep sama.

## Fitur Buat Admin

### Dashboard
Dashboard-nya lengkap banget, ada overview operasional hari ini: total antrian, yang lagi dilayani, yang nunggu, yang udah selesai. Semua dikelompokkin per poli biar gampang monitoring.

### Kontrol Antrian
Admin bisa panggil antrian berikutnya cuma dengan satu tap. Bisa skip kalo pasiennya ga dateng, atau tandain udah selesai. Setiap aksi langsung keupdate di layar display sama notif ke pasien.

### Kelola Pasien
Bisa liat semua pasien yang udah daftar, ada fitur search berdasarkan nama, email, atau nomor HP. Detail pasien nunjukin info lengkap sama history kunjungannya.

### Atur Poli
CRUD lengkap buat poli: tambah, edit, hapus. Bisa atur nama, deskripsi, sama status aktif atau ga. Kalo lagi ga operasional tinggal dinonaktifin aja.

### Kelola Dokter
Bisa manage data dokter: tambah, edit, hapus. Info dokter lengkap ada nama, spesialisasi, nomor HP, sama poli tempat dia praktek.

### Jadwal Dokter
Atur jadwal praktek dokter per hari, jam mulai sampe jam selesai. Jadwal ini yang bakal ditampilin ke pasien waktu mau ambil antrian.

### Setting Antrian
Tiap poli punya setting sendiri: jam buka, jam tutup, max antrian per hari, sama estimasi waktu pelayanan. Setting ini yang dipake buat ngitung estimasi waktu tunggu.

### Laporan
Generate laporan antrian berdasarkan periode tertentu, ada statistik lengkapnya. Bisa di-export ke PDF buat dokumentasi atau presentasi. Laporan-nya detail, ada breakdown per poli sama status antrian.

### Audit Log
Tracking lengkap semua yang dilakuin admin. Setiap ubah data tercatat: siapa yang ngubah, kapan, sama perubahannya apa. Berguna banget buat accountability sama troubleshooting.

### Aksi Massal
Admin bisa lakuin aksi ke banyak antrian sekaligus. Misalnya batal banyak antrian sekaligus dengan satu alasan, atau reset semua antrian buat tanggal tertentu. Ada konfirmasi dialog biar ga salah pencet.

## Layar Display Antrian

Ini layar khusus buat ditampilin di TV atau monitor di ruang tunggu. Nunjukin nomor antrian yang lagi dipanggil per poli. Auto-refresh tiap 5 detik biar selalu update. Ga perlu login, langsung bisa diakses.

## State Management

Pake Provider pattern buat manage state. AuthProvider handle state login sama session user. State-nya sync di semua screen yang butuh.

## Integrasi API

Semua komunikasi sama backend lewat service layer yang terstruktur. ApiService handle HTTP request dengan header authentication otomatis. Error handling-nya konsisten di semua endpoint.

## Fitur Offline

Token authentication disimpen di local pake SharedPreferences. User tetep login meskipun aplikasi ditutup. Auto-logout kalo token expired atau invalid.

## Design UI/UX

Interface-nya clean dan modern pake Material Design. Warna konsisten pake theme configuration. Loading state sama error message-nya jelas. Layout responsive buat berbagai ukuran layar.

## Push Notification

Integrasi sama Firebase Cloud Messaging buat notifikasi real-time. Pasien dapet notif waktu antriannya dipanggil. Notification handling jalan baik pas app lagi dibuka atau di background.

## Keamanan

Pake token-based authentication buat semua endpoint yang protected. Role-based access control buat misahin fitur admin sama pasien. Input validation di client side sebelum dikirim ke server.

## Performa

Lazy loading buat list data yang panjang. Image caching buat performa lebih baik. State update yang efisien biar ga rebuild yang ga perlu. Pagination buat data yang banyak.
