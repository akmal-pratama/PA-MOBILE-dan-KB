<h1>🍳 Dapur Pintar</h1>

<p>Dapur Pintar adalah aplikasi penyimpanan resep makanan berbasis Flutter yang memungkinkan pengguna menemukan resep berdasarkan bahan-bahan yang mereka miliki. Aplikasi ini merupakan proyek kolaborasi untuk memenuhi tugas project akhir praktikum mata kuliah Kecerdasan Buatan dan Pemrograman Mobile.</p>

<p>Aplikasi ini terhubung dengan Cloud Firestore untuk manajemen resep dan menggunakan API eksternal di Hugging Face untuk mendeteksi bahan makanan melalui gambar.</p>

<hr>

<h2>✨ Fitur Utama</h2>

<ul>
    <li><strong>Jelajahi Resep:</strong> Menampilkan daftar resep yang diambil secara <i>real-time</i> dari Cloud Firestore.</li>
    <li><strong>Pindai Bahan (AI):</strong> Memindai bahan makanan menggunakan kamera atau galeri. Aplikasi akan mengirim gambar ke API eksternal untuk dideteksi dan kemudian menampilkan resep yang cocok.</li>
    <li><strong>Pencarian & Filter:</strong> Mencari resep berdasarkan nama, dan memfilter berdasarkan durasi memasak, tingkat kesulitan, kategori, serta bahan yang harus ada atau tidak boleh ada.</li>
    <li><strong>Resep Favorit:</strong> Menyimpan resep yang disukai ke daftar favorit.</li>
    <li><strong>Manajemen Resep (CRUD):</strong> Pengguna dapat menambah, mengedit, dan menghapus resep mereka sendiri.</li>
</ul>

<hr>

<h2>💻 Teknologi yang Digunakan</h2>

<ul>
    <li><strong>Framework:</strong> Flutter</li>
    <li><strong>Bahasa:</strong> Dart</li>
    <li><strong>Database (Online):</strong> Firebase Cloud Firestore</li>
    <li><strong>Database (Lokal):</strong> SharedPreferences (untuk resep favorit)</li>
    <li><strong>State Management:</strong> Flutter Riverpod</li>
    <li><strong>Routing:</strong> GoRouter</li>
    <li><strong>API (AI):</strong> Gradio API yang di-host di Hugging Face untuk deteksi bahan.</li>
    <li><strong>Lainnya:</strong> <code>image_picker</code>, <code>http</code></li>
</ul>

<hr>

<h2>🚀 Cara Menjalankan Proyek</h2>

<p>Untuk menjalankan proyek ini di lingkungan pengembangan Anda, ikuti langkah-langkah berikut:</p>

<ol>
    <li>
        <strong>Buka Folder anda</strong>
        <p>Selanjutnya buka folder tempat anda ingin menaruh program, lalu arahkan cursor ke alamat folder diatas dan klik, setelah itu ketikkan cmd hingga terbuka terminal command line</p>
    </li>
    <li>
        <strong>Clone Repositori</strong>
        <pre><code>git clone https://github.com/Fakemedusa45/dapur_pintar</code></pre>
    </li>
    <li>
        <strong>Konfigurasi Firebase</strong>
        <p>Proyek ini memerlukan Firebase untuk berfungsi.</p>
        <ul>
            <li>Buat proyek baru di <a href="https://console.firebase.google.com/">Firebase Console</a>.</li>
            <li>Aktifkan <strong>Cloud Firestore</strong> sebagai database.</li>
            <li>Daftarkan aplikasi Anda untuk Android, iOS, dan Web.</li>
            <li>Unduh file <code>google-services.json</code> dan letakkan di <code>android/app/</code>.</li>
            <li>Salin konfigurasi Firebase untuk Flutter (dari pengaturan proyek) dan paste ke dalam file <code>lib/firebase_options.dart</code>.</li>
        </ul>
    </li>
    <li>
        <strong>Install Dependensi</strong>
        <pre><code>flutter pub get</code></pre>
    </li>
    <li>
        <strong>Jalankan Aplikasi</strong>
        <pre><code>flutter run</code></pre>
    </li>
</ol>

<hr>

<h2>🤖 Menjalankan Server (Informasi API)</h2>

<p>Aplikasi ini <strong>tidak memerlukan server lokal</strong> untuk dijalankan.</p>

<p>Fitur pemindaian bahan (AI) menggunakan API eksternal yang sudah di-deploy dan di-host di Hugging Face Space. Endpoint API ini didefinisikan dalam file <code>lib/application/notifiers/scan_notifier.dart</code>:</p>

<ul>
    <li><strong>Endpoint:</strong> <code>https://GalaxionZero-raw-indonesian-food-detection.hf.space</code></li>
</ul>

<p>Selama layanan API di Hugging Face tersebut aktif dan dapat diakses oleh publik, fitur pemindaian bahan akan berfungsi tanpa perlu konfigurasi tambahan.</p>

<hr>

<h2>🕹️ Cara Menggunakan Aplikasi</h2>

<ol>
    <li><strong>Halaman Utama:</strong> Buka aplikasi untuk melihat daftar resep. Gunakan <i>search bar</i> untuk mencari, atau ikon filter (corong) untuk menyaring resep.</li>
    <li>
        <strong>Pindai Bahan:</strong>
        <ul>
            <li>Buka tab <strong>"Pindai"</strong> (ikon kamera) di navigasi bawah.</li>
            <li>Pilih gambar dari <strong>"Galeri"</strong> atau ambil foto baru dengan <strong>"Kamera"</strong>. Anda bisa memilih hingga 5 gambar.</li>
            <li>Tekan tombol <strong>"Pindai Bahan"</strong>. Aplikasi akan memproses gambar dan menampilkan daftar bahan yang terdeteksi.</li>
            <li>Tekan <strong>"Cari Resep Berdasarkan Bahan Ini"</strong> untuk kembali ke Halaman Utama dengan filter bahan hasil pindaian.</li>
        </ul>
    </li>
    <li><strong>Tambah/Edit Resep:</strong>
        <ul>
            <li>Di Halaman Utama, tekan tombol <code>+</code> untuk menambah resep baru.</li>
            <li>Di halaman Detail Resep, tekan ikon pensil (edit) untuk mengubah resep.</li>
        </ul>
    </li>
    <li><strong>Resep Favorit:</strong>
        <ul>
            <li>Saat melihat detail resep, tekan ikon bintang (⭐️) di kanan atas untuk menyimpan resep ke favorit.</li>
            <li>Lihat semua resep favorit Anda di tab <strong>"Favorit"</strong>.</li>
        </ul>
    </li>
</ol>

<hr>

<h2>📁 Tautan Google Drive</h2>

<p>aplikasi dapat diakses melalui tautan Google Drive di bawah ini:</p>

<p>
    <a href="https://link.gdrive.placeholder.com"><strong>[Link Google Drive]</strong></a>
</p>
