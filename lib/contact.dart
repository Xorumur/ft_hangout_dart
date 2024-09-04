// class Contact {
//   final int? id;
//   final String firstName;
//   final String lastName;
//   final String phone;
//   final String email;
//   final int age;
//   final String? image;

//   Contact(Map<dynamic, Object?> map, {
//     this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.phone,
//     required this.email,
//     required this.age,
//     required this.image,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'firstName': firstName,
//       'lastName': lastName,
//       'phone': phone,
//       'email': email,
//       'age': age,
//       'image': image,
//     };
//   }

//   static Contact fromMap(Map<String, dynamic> map) {
//     return Contact(
//       id: map['id'],
//       firstName: map['firstName'],
//       lastName: map['lastName'],
//       phone: map['phone'],
//       email: map['email'],
//       age: map['age'],
//       image: map['image'],
//     );
//   }

// Contact copyWith({
//     int? id,
//     String? firstName,
//     String? lastName,
//     String? phone,
//     String? email,
//     int? age,
//     String? image,
//   }) {
//     return Contact(
//       id: id ?? this.id,
//       firstName: firstName ?? this.firstName,
//       lastName: lastName ?? this.lastName,
//       phone: phone ?? this.phone,
//       email: email ?? this.email,
//       age: age ?? this.age,
//       image: image ?? this.image,
//     );
//   }
// }

class Contact {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final int age;
  final String? image;

  Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.age,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'age': age,
      'image': image,
    };
  }

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      email: map['email'],
      age: map['age'],
      image: map['image'],
    );
  }

  Contact copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    int? age,
    String? image,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      age: age ?? this.age,
      image: image ?? this.image,
    );
  }
}
