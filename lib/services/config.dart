class Config {
  static String baseUrl = "https://demarcheur-backend.onrender.com/api/v1";

  static String? getImgUrl(String? path) {
    if (path == null || path.isEmpty || path == "null") return null;
    if (path.startsWith('http')) return path;
    String cleanPath = path.startsWith('/') ? path : "/$path";
    return "https://demarcheur-backend.onrender.com$cleanPath";
  }
}
