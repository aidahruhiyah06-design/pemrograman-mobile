import 'package:intl/intl.dart';

String formatRupiah(int angka) {
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(angka);
}

String formatTanggalIndo(String tanggalYmd) {
  final date = DateTime.parse(tanggalYmd);
  return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
}
