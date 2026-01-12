import 'phone_number.dart';

/// Représente les informations de contact d'un parent/tuteur.
class ParentContact {
  final String name;
  final List<PhoneNumber> phoneNumbers;
  final ParentRelation relation;

  const ParentContact({
    required this.name,
    this.phoneNumbers = const [],
    required this.relation,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumbers': phoneNumbers.map((p) => p.toJson()).toList(),
        'relation': relation.toString().split('.').last,
      };

  factory ParentContact.fromJson(Map<String, dynamic> json) {
    return ParentContact(
      name: json['name'] as String,
      phoneNumbers: (json['phoneNumbers'] as List<dynamic>?)
              ?.map((p) => PhoneNumber.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      relation: ParentRelation.values.firstWhere(
        (e) => e.toString().split('.').last == json['relation'],
        orElse: () => ParentRelation.other,
      ),
    );
  }
}

/// Relation du parent/tuteur avec le membre.
enum ParentRelation {
  mother,
  father,
  guardian,
  other,
}
