<p align="center">
  <img src="docs/preview/hero.png" alt="Dicoding Story App — ilustrasi aplikasi berbagi cerita" width="100%">
</p>

<h1 align="center">Dicoding Story App</h1>

<p align="center">
  <b>Bagikan cerita, lihat cerita orang lain, lengkap dengan lokasi.</b><br>
  Dwibahasa (EN/ID) dan notifikasi latar belakang.
</p>

<p align="center">
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"></a>
  <img alt="State" src="https://img.shields.io/badge/State-Provider-5C6BC0">
  <img alt="Maps" src="https://img.shields.io/badge/Maps-Google%20Maps-4285F4?logo=googlemaps&logoColor=white">
  <img alt="i18n" src="https://img.shields.io/badge/i18n-EN%20%2F%20ID-0D9488">
</p>

---

## ✨ Preview

<p align="center">
  <img src="docs/preview/hero.png" alt="Mockup gelap Dicoding Story App" width="90%">
</p>

<table align="center">
  <tr>
    <td><img src="screenshots/splash_screen.png" alt="Splash" width="190"></td>
    <td><img src="screenshots/login_screen_en.png" alt="Login English" width="190"></td>
    <td><img src="screenshots/login_screen_id.png" alt="Login Indonesia" width="190"></td>
    <td><img src="screenshots/stories_list_id.png" alt="Daftar cerita" width="190"></td>
  </tr>
  <tr>
    <td align="center">Splash</td>
    <td align="center">Login (EN)</td>
    <td align="center">Login (ID)</td>
    <td align="center">Stories (ID)</td>
  </tr>
</table>

<table align="center">
  <tr>
    <td><img src="screenshots/stories_list_en.png" alt="Stories English" width="190"></td>
    <td><img src="screenshots/add_story_camera.png" alt="Tambah cerita via kamera" width="190"></td>
    <td><img src="screenshots/add_story_gallery.png" alt="Tambah cerita via galeri" width="190"></td>
    <td><img src="screenshots/notifications.png" alt="Notifikasi" width="190"></td>
  </tr>
  <tr>
    <td align="center">Stories (EN)</td>
    <td align="center">Add story — kamera</td>
    <td align="center">Add story — galeri</td>
    <td align="center">Notifikasi</td>
  </tr>
</table>

---

## 📖 Tentang

Aplikasi berbagi cerita dengan foto, peta lokasi, dan dukungan dua bahasa. Dibangun dengan
Flutter, `go_router` untuk navigasi, `provider` untuk state, serta `workmanager` untuk
notifikasi latar belakang.

---

## 🌟 Fitur

- **Story sharing** — unggah cerita dengan gambar dari kamera atau galeri
- **Story discovery** — jelajahi cerita pengguna lain dengan timestamp
- **Autentikasi** — login dan registrasi
- **Multibahasa** — Inggris dan Bahasa Indonesia (l10n)
- **Peta & lokasi** — `google_maps_flutter` dan `location`
- **Notifikasi pintar** — notifikasi latar belakang untuk cerita baru
- **Flavors** — konfigurasi build per environment

---

## 🛠️ Tech Stack

| Area | Pilihan |
|---|---|
| Framework | Flutter |
| State management | Provider |
| Routing | GoRouter |
| Peta | Google Maps Flutter |
| Latar belakang | Workmanager + local notifications |
| Lokalisasi | `flutter_localizations` + l10n |
| Media | `image_picker` |

---

## 🚀 Menjalankan

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Siapkan API key Google Maps dan konfigurasi project sesuai flavors yang dipakai.

---

## 🧪 Testing

```bash
flutter analyze
flutter test
```
