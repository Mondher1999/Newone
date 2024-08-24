class HousingFile {
  final String id;
  final String userId;
  final String cin;
  final String bulletinSalaire;
  final String impots;
  final String facture;
  final String quittance;
  final String identiteBancaire;
  final String etatLieu;

  HousingFile({
    required this.id,
    required this.userId,
    required this.cin,
    required this.bulletinSalaire,
    required this.impots,
    required this.facture,
    required this.quittance,
    required this.identiteBancaire,
    required this.etatLieu,
  });

  HousingFile.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        userId = json['userId'] ?? '',
        cin = json['cin'] ?? '',
        bulletinSalaire = json['d_bulletin_salaire'] ?? '',
        impots = json['impots'] ?? '',
        facture = json['d_facture'] ?? '',
        quittance = json['d_quittance'] ?? '',
        identiteBancaire = json['re_identite_bancaire'] ?? '',
        etatLieu = json['d_etat_lieu'] ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'cin': cin,
        'd_bulletin_salaire': bulletinSalaire,
        'impots': impots,
        'd_facture': facture,
        'd_quittance': quittance,
        're_identite_bancaire': identiteBancaire,
        'd_etat_lieu': etatLieu,
      };
}
