/// Représente un numéro de téléphone avec son type.
class PhoneNumber {
  final String number;
  final PhoneType type;

  const PhoneNumber({
    required this.number,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'type': type.toString().split('.').last,
      };

  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    return PhoneNumber(
      number: json['number'] as String,
      type: PhoneType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PhoneType.regular,
      ),
    );
  }
}

/// Type de numéro de téléphone.
enum PhoneType {
  regular,
  whatsapp,
}
