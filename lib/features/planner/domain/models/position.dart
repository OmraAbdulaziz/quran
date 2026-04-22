/// موضع في القرآن يمثَّل بسورة وآية.
class Position implements Comparable<Position> {
  final int surah;
  final int ayah;

  const Position(this.surah, this.ayah);

  factory Position.fromMap(Map<String, dynamic> m, String prefix) =>
      Position(m['${prefix}_surah'] as int, m['${prefix}_ayah'] as int);

  Map<String, Object?> toMap(String prefix) => {
        '${prefix}_surah': surah,
        '${prefix}_ayah': ayah,
      };

  @override
  int compareTo(Position other) {
    final s = surah.compareTo(other.surah);
    return s != 0 ? s : ayah.compareTo(other.ayah);
  }

  bool operator <(Position other) => compareTo(other) < 0;
  bool operator <=(Position other) => compareTo(other) <= 0;
  bool operator >(Position other) => compareTo(other) > 0;
  bool operator >=(Position other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Position && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => '$surah:$ayah';
}
