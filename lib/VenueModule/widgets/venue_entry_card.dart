import 'package:flutter/material.dart';
import 'package:gas_in/VenueModule/models/venue_model.dart';

class VenueEntryCard extends StatelessWidget {
  final VenueEntry venue;
  final VoidCallback onTap;

  const VenueEntryCard({super.key, required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Container dengan dekorasi manual daripada Card bawaan
    // untuk mendapatkan efek shadow yang lebih halus dan tanpa border outline.
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 4,
      ), // Sedikit margin luar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0), // Sudut kartu lebih bulat
        boxShadow: [
          // Layered shadows for a more natural elevated look
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Material & InkWell diperlukan agar efek riak (ripple) saat diklik tetap ada
      // dan mengikuti bentuk rounded corners.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAGIAN GAMBAR ---
              // ClipRRect hanya membulatkan sudut ATAS gambar
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6.0),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: venue.thumbnail.trim().isNotEmpty
                      ? Image.network(
                          // Proxying remote image through local backend
                          'http://localhost:8000/api/proxy-image/?url=${Uri.encodeComponent(venue.thumbnail)}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/venue.jpg',
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.asset(
                          'assets/venue.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              // --- BAGIAN KONTEN TEKS ---
              Padding(
                padding: const EdgeInsets.all(
                  30.0,
                ), // Padding di sekeliling teks
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Label Kategori (Pill Ungu)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0B3FF), // Warna ungu muda
                        borderRadius: BorderRadius.circular(20), // Bentuk pill
                      ),
                      child: Text(
                        venue.category
                            .toUpperCase(), // Menggunakan data kategori
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. Judul (Nama Venue)
                    Text(
                      venue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18.0, // Font lebih besar
                        fontWeight: FontWeight.w800, // Lebih tebal
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 3. Deskripsi
                    Text(
                      // Menggunakan lorem ipsum jika deskripsi kosong, atau potong jika terlalu panjang
                      venue.description.isEmpty
                          ? "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                          : (venue.description.length > 100
                                ? '${venue.description.substring(0, 100)}...'
                                : venue.description),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            Colors.grey[600], // Warna abu-abu untuk deskripsi
                        fontSize: 13.0,
                        height: 1.3, // Jarak antar baris
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
