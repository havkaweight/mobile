class Gender {
  final String name;
  final String slug;

  Gender({
    required this.name,
    required this.slug,
  });

  static List<Gender> list() {
    return [
      Gender(name: "Male", slug: "male"),
      Gender(name: "Female", slug: "female"),
      Gender(name: "Other", slug: "other"),
    ];
  }

  static Gender getBySlug(String slug) {
    return Gender.list().firstWhere((element) => element.slug == slug);
  }

  static Gender getByName(String name) {
    return Gender.list().firstWhere((element) => element.name == name);
  }
}