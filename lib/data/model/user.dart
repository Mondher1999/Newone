class Users {
  final String id;
  final String nom;
  final String prenom;
  final String adresse;
  final String dateNaissance;
  final String role;
  final String numeroTel;
  final String? fileUrl;
  final String email;
  final String? maritalSatiation;
  final String? nbrChildren;
  final String? monthlyIncome;
  final String? moveInDate;
  final String? housingAid;
  final String? noticePeriod;
  final String? jobSatiation;
  final String? validefilesuser;

  final String? valideinfouser;

  // Existing constructor remains unchanged to maintain compatibility
  Users({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.role,
    required this.adresse,
    required this.numeroTel,
    required this.fileUrl, // Now optional
    required this.email,
    this.maritalSatiation,
    this.nbrChildren,
    this.monthlyIncome,
    this.moveInDate,
    this.housingAid,
    this.noticePeriod,
    this.jobSatiation,
    this.validefilesuser,
    this.valideinfouser,
  });

  // Named constructor without fileUrl
  Users.withoutFileUrl({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.role,
    required this.adresse,
    required this.numeroTel,
    required this.email,
    required this.maritalSatiation,
    required this.nbrChildren,
    required this.monthlyIncome,
    required this.moveInDate,
    required this.housingAid,
    required this.noticePeriod,
    required this.jobSatiation,
    this.validefilesuser,
    this.valideinfouser,
    this.fileUrl,

    // Default to an empty string or any default value you prefer
  });

  Users copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? adresse,
    String? numeroTel,
    String? fileUrl,
    String? dateNaissance,
    String? email,
    String? role,
    String? maritalSatiation,
    String? nbrChildren,
    String? monthlyIncome,
    String? moveInDate,
    String? housingAid,
    String? noticePeriod,
    String? jobSatiation,
    String? validefilesuser,
    String? valideinfouser,
  }) {
    return Users(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      role: role ?? this.role,
      adresse: adresse ?? this.adresse,
      numeroTel: numeroTel ?? this.numeroTel,
      email: email ?? this.email,
      fileUrl: fileUrl ?? this.fileUrl,
      maritalSatiation: maritalSatiation ?? this.maritalSatiation,
      nbrChildren: nbrChildren ?? this.nbrChildren,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      moveInDate: moveInDate ?? this.moveInDate,
      housingAid: housingAid ?? this.housingAid,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      jobSatiation: jobSatiation ?? this.jobSatiation,
      validefilesuser: validefilesuser ?? this.validefilesuser,
      valideinfouser: valideinfouser ?? this.valideinfouser,
    );
  }

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      numeroTel: json['numeroTel'] ?? '',
      adresse: json['adresse'] ?? '',
      dateNaissance: json['dateNaissance'] ?? '',
      email: json['email'] ?? '',
      fileUrl: json['fileUrl'], // Accepts null
      role: json['role'] ?? '',
      maritalSatiation: json['maritalSatiation'] ?? '',
      nbrChildren: json['nbrChildren']?.toString() ?? '0',
      monthlyIncome: json['monthlyIncome']?.toString() ?? '0',
      moveInDate: json['moveInDate'] ?? '',
      housingAid: json['housingAid']?.toString() ?? '0',
      noticePeriod: json['noticePeriod'] ?? '',
      jobSatiation: json['jobSatiation'] ?? '',
      validefilesuser: json['validefilesuser'] ?? '',
      valideinfouser: json['valideinfouser'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'adresse': adresse,
        'numeroTel': numeroTel,
        'dateNaissance': dateNaissance,
        'email': email,
        'fileUrl': fileUrl,
        'role': role,
        'maritalSatiation': maritalSatiation,
        'nbrChildren': nbrChildren,
        'monthlyIncome': monthlyIncome,
        'moveInDate': moveInDate,
        'housingAid': housingAid,
        'noticePeriod': noticePeriod,
        'jobSatiation': jobSatiation,
        'validefilesuser': validefilesuser,
        'valideinfouser': valideinfouser,
      };
}
