import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Пользователь с вложенными моделями Address и Company.
@JsonSerializable(explicitToJson: true)
class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phone,
    this.website,
    this.address,
    this.company,
  });

  final int id;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: '')
  final String username;

  @JsonKey(defaultValue: '')
  final String email;

  final String? phone;
  final String? website;
  final Address? address;
  final Company? company;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Address {
  const Address({this.street, this.suite, this.city, this.zipcode});

  final String? street;
  final String? suite;
  final String? city;
  final String? zipcode;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

@JsonSerializable()
class Company {
  const Company({this.name, this.catchPhrase});

  final String? name;
  final String? catchPhrase;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
