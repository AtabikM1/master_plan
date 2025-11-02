1. Penjelasan InheritedWidget (Langkah 1)
Mana yang dimaksud InheritedWidget?

InheritedWidget adalah class induk (parent) dari InheritedNotifier.

Dalam kode Anda di Langkah 1: class PlanProvider extends InheritedNotifier<...>

Jika kita lihat dokumentasi Flutter, InheritedNotifier itu sendiri: class InheritedNotifier<T> extends InheritedWidget

Jadi, PlanProvider yang Anda buat adalah sebuah InheritedWidget secara tidak langsung.

Mengapa menggunakan InheritedNotifier (bukan InheritedWidget biasa)?

InheritedWidget murni dirancang untuk meneruskan data ke bawah (ke descendant), tetapi tidak dirancang untuk memberi tahu widget di bawahnya ketika data itu berubah. Jika data di InheritedWidget murni berubah, Anda harus membangun ulang (rebuild) InheritedWidget itu sendiri, yang seringkali tidak efisien.

InheritedNotifier adalah "jembatan" yang cerdas. Ia melakukan dua hal:

Bertindak sebagai InheritedWidget: Ia menyediakan data (dalam kasus ini, ValueNotifier<Plan>) ke widget apa pun di bawahnya yang memintanya (menggunakan PlanProvider.of(context)).

Membawa Notifier: Ia menampung sebuah Listenable (dalam kasus ini, ValueNotifier).

Keuntungannya: Ketika nilai ValueNotifier berubah (misalnya, Anda menambah task baru), ValueNotifier akan "memberi tahu" semua yang mendengarkannya. ValueListenableBuilder di PlanScreen akan otomatis rebuild untuk menampilkan data baru, tanpa perlu membangun ulang PlanProvider itu sendiri.

Singkatnya: InheritedNotifier digunakan agar widget anak (seperti PlanScreen) bisa "mendengarkan" perubahan data secara efisien tanpa harus membangun ulang seluruh pohon widget dari atas.

2. Penjelasan Method (Langkah 3)
Apa maksud dari kedua method (getter) tersebut?

Dart

// Di dalam class Plan
int get completedCount => tasks
  .where((task) => task.complete)
  .length;

String get completenessMessage =>
  '$completedCount out of ${tasks.length} tasks';
Ini adalah dua getter (fungsi yang bertindak seperti variabel) di dalam model Plan:

completedCount:

tasks.where((task) => task.complete): Ini akan mem-filter daftar tasks dan hanya mengembalikan daftar baru yang berisi task yang properti complete-nya adalah true.

.length: Ini menghitung jumlah task di dalam daftar yang sudah difilter tadi.

Hasil: completedCount adalah sebuah angka (integer) yang memberi tahu "jumlah task yang sudah selesai".

completenessMessage:

Ini adalah getter yang menggunakan hasil dari completedCount di atas.

Ia membuat sebuah string (teks) yang diformat, misalnya: "2 out of 5 tasks".

Hasil: completenessMessage adalah sebuah teks (String) yang siap ditampilkan di UI untuk menunjukkan progres.

Mengapa dilakukan demikian? (Prinsip Separation of Concerns)

Ini adalah praktik coding yang sangat baik yang disebut Pemisahan Logika (Separation of Concerns).

Sebelumnya: Logika untuk menghitung task yang selesai mungkin akan Anda tulis di dalam file UI (plan_screen.dart).

Sekarang (Cara yang Benar): Logika tersebut dipindahkan ke dalam model (plan.dart).

Alasannya:

Model Plan harus "tahu" segalanya tentang dirinya sendiri. Ini termasuk daftar task-nya, dan juga data turunan (derived data) seperti "berapa banyak task yang selesai".

UI (PlanScreen) tidak perlu tahu cara menghitungnya. UI hanya perlu menampilkan hasilnya. UI tinggal memanggil plan.completenessMessage dan menampilkannya di Text.

Ini membuat kode UI Anda (plan_screen.dart) jauh lebih bersih dan kode logika bisnis Anda (plan.dart) terorganisir di satu tempat.

3. Hasil GIF (Langkah 9) dan Penjelasannya
Saya adalah model teks dan tidak dapat menjalankan kode Flutter untuk merekam atau membuat file GIF.

Namun, saya dapat menjelaskan dengan pasti apa yang akan ditampilkan oleh GIF tersebut berdasarkan kode yang telah Anda buat:

Deskripsi Isi GIF:

Aplikasi akan terbuka menampilkan layar "Master Plan" dengan sebuah app bar dan tombol + (FloatingActionButton). Awalnya, layar kosong dan di bagian bawah tertulis "0 out of 0 tasks".

Pengguna menekan tombol +. Seketika, sebuah baris task baru muncul di layar (sebuah checkbox dan sebuah kotak teks kosong).

Teks di bagian bawah layar akan langsung diperbarui menjadi "0 out of 1 tasks".

Pengguna mengetik "Selesaikan Laporan Praktikum" di dalam kotak teks.

Pengguna menekan tombol + lagi. Task kedua muncul. Teks di bawah berubah menjadi "0 out of 2 tasks".

Pengguna mengetik "Beli susu" di task kedua.

Pengguna kemudian menekan checkbox di sebelah "Selesaikan Laporan Praktikum". Checkbox itu langsung tercentang.

Teks progres di bagian bawah layar secara reaktif langsung berubah menjadi "1 out of 2 tasks".

Pengguna menekan checkbox kedua. Teks progres berubah lagi menjadi "2 out of 2 tasks".

Pengguna menghapus centang di task pertama. Teks progres kembali menjadi "1 out of 2 tasks".


### praktikum 1

Penjelasan Langkah 4 (Modifikasi _buildAddTaskButton & _buildTaskTile)
Apa yang dilakukan? Pada langkah ini, Anda mengubah dua method (_buildAddTaskButton dan _buildTaskTile) dari yang tadinya memanggil setState() menjadi:

Menerima BuildContext context sebagai parameter.

Menggunakan PlanProvider.of(context) untuk mendapatkan ValueNotifier<Plan>.

Memperbarui state dengan mengubah .value dari notifier tersebut: planNotifier.value = Plan(...).

Mengapa dilakukan demikian? (Pemisahan Tanggung Jawab)

Ini adalah inti dari perpindahan dari local state (setState) ke state management terpusat (InheritedNotifier).

Sebelumnya (dengan setState): PlanScreen bertanggung jawab untuk memegang data (Plan plan = ...) sekaligus memperbarui UI (setState).

Sekarang (dengan PlanProvider): Tanggung jawabnya dipisah:

PlanProvider: Bertugas memegang data (ValueNotifier).

PlanScreen: Bertugas membaca data (via ValueListenableBuilder) dan mengirim perintah perubahan (via PlanProvider.of(context).value = ...).

_buildAddTaskButton tidak lagi perlu tahu bagaimana UI akan diperbarui. Ia hanya perlu tahu "di mana" pusat data berada (PlanProvider.of(context)) dan mengirimkan data baru ke sana. ValueListenableBuilder (di Langkah 7) yang akan otomatis "mendengar" perubahan itu dan membangun ulang UI yang diperlukan.

Ini membuat kode lebih bersih, terorganisir, dan efisien karena tidak seluruh widget PlanScreen perlu di-rebuild setiap ada perubahan.

📦 2. Penjelasan Langkah 6 (Variabel plan di _buildList)
Mengapa perlu variabel plan di _buildList(Plan plan)?

Karena _PlanScreenState tidak lagi memiliki variabel plan di dalam state-nya (baris Plan plan = const Plan(); sudah dihapus).

_buildList adalah method yang tugasnya hanya membangun ListView berdasarkan data yang diberikan. Karena ia tidak lagi memiliki data internal, data tersebut harus "diberikan" kepadanya.

Data plan ini sekarang berasal dari ValueListenableBuilder di dalam build method Anda:

Dart

ValueListenableBuilder<Plan>(
  valueListenable: PlanProvider.of(context),
  builder: (context, plan, child) { 
    // ^--- 'plan' ini adalah data terbaru dari provider
    
    return Column(
      children: [
        // Data 'plan' dikirim ke _buildList
        Expanded(child: _buildList(plan)), 
        ...
      ],
    );
  },
),
Setiap kali PlanProvider memiliki nilai plan baru, ValueListenableBuilder akan menjalankan fungsi builder-nya, memberikan plan terbaru itu, yang kemudian diteruskan ke _buildList untuk ditampilkan.

Mengapa (nilai awalnya) dibuat const?

Anda merujuk pada const Plan() yang digunakan di main.dart: notifier: ValueNotifier<Plan>(const Plan())

const adalah singkatan dari konstanta (constant).

Imutabilitas: Plan adalah class yang immutable (tidak bisa diubah). Anda tidak pernah mengubah properti objek Plan yang ada. Sebaliknya, Anda membuat objek Plan yang baru setiap kali ada perubahan.

Performa: const Plan() adalah compile-time constant. Ini memberi tahu Dart bahwa objek ini dibuat saat compile (bukan saat runtime) dan nilainya tidak akan pernah berubah. Ini sangat efisien dan cepat.

Jadi, const Plan() digunakan sebagai nilai awal yang sempurna: sebuah objek Plan kosong yang dijamin tidak akan pernah berubah dan sangat ringan untuk dibuat.

🎞️ 3. Hasil GIF (Langkah 9) dan Penjelasan
Saya adalah model AI berbasis teks dan tidak dapat menjalankan kode Flutter atau merekam layar untuk membuat file GIF.

Namun, saya bisa menjelaskan dengan rinci apa yang akan Anda lihat di GIF tersebut dan apa yang telah Anda buat:

Deskripsi Isi GIF:

Aplikasi terbuka, menampilkan judul "Master Plan". Di bagian bawah, ada teks "0 out of 0 tasks".

Pengguna menekan tombol + (FloatingActionButton).

Sebuah task baru (checkbox dan field teks) langsung muncul di layar.

Secara bersamaan, teks di bawah berubah menjadi "0 out of 1 tasks".

Pengguna mengetik "Selesaikan Praktikum" di task pertama.

Pengguna menekan tombol + lagi. Task kedua muncul, dan teks di bawah berubah menjadi "0 out of 2 tasks".

Pengguna mengetik "Upload ke GitHub" di task kedua.

Pengguna menekan checkbox di sebelah "Selesaikan Praktikum". Checkbox itu tercentang.

Teks di bawah langsung berubah menjadi "1 out of 2 tasks".

Pengguna menekan checkbox kedua. Teks di bawah berubah lagi menjadi "2 out of 2 tasks".

Pengguna membatalkan centang task pertama. Teks progres kembali menjadi "1 out of 2 tasks".

Penjelasan Apa yang Telah Dibuat:

Anda telah membuat aplikasi To-Do List yang reaktif. "Reaktif" berarti UI (tampilan) secara otomatis "bereaksi" terhadap perubahan data (state).

Anda mencapainya dengan memisahkan state (objek Plan) dari UI (PlanScreen). State tersebut dibungkus dalam ValueNotifier dan disediakan oleh PlanProvider. UI menggunakan ValueListenableBuilder untuk "mendengarkan" perubahan pada state tersebut.

Hasilnya, ketika Anda menambah task atau mencentang checkbox (yang memperbarui state), ValueListenableBuilder otomatis mendeteksinya dan membangun ulang bagian UI yang relevan (daftar task dan teks progres) untuk menampilkan data terbaru.

🔄 4. Kegunaan Method (Langkah 11 & 13) dalam Lifecycle State
initState dan dispose adalah dua method paling penting dalam siklus hidup (lifecycle) sebuah State pada StatefulWidget.

initState() (Langkah 11)

Kapan dipanggil? Dipanggil satu kali saja, yaitu ketika objek State pertama kali dibuat dan dimasukkan ke dalam widget tree.

Apa gunanya? Untuk melakukan pekerjaan setup awal yang hanya perlu dilakukan sekali. Ini adalah tempat yang tepat untuk:

Menginisialisasi controller (seperti ScrollController, TextEditingController).

Berlangganan (subscribe) ke stream atau listener lain.

Di praktikum ini: Anda menggunakannya untuk menginisialisasi scrollController dan menambahkan listener padanya (..addListener(...)) untuk menutup keyboard saat layar di-scroll.

dispose() (Langkah 13)

Kapan dipanggil? Dipanggil satu kali saja, yaitu ketika objek State akan dihancurkan secara permanen (misalnya, saat Anda pindah ke layar lain).

Apa gunanya? Untuk "membersihkan" semua yang Anda buat di initState agar tidak terjadi kebocoran memori (memory leak). Jika Anda tidak melakukan dispose:

Controller dan listener akan tetap ada di memori meskipun widget-nya sudah tidak ada.

Ini akan menghabiskan memori dan bisa menyebabkan error jika listener mencoba memperbarui widget yang sudah tidak ada.

Di praktikum ini: Anda memanggil scrollController.dispose() untuk membersihkan controller tersebut dari memori dengan benar.