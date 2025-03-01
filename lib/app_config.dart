var this_year = DateTime.now().year.toString();

class AppConfig {
  // this shows in the splash screen
  // static String copyright_text = "@" + this_year;
  static String copyright_text = "";

  // this shows in the splash screen
  static String app_name = "G&B";

  // enter your purchase code for the app from codecanyon
  static String purchase_code = "XXXXXXXXXXXX";

  /// Enter system key code generated from https://activeitzone.com/activation
  /// Replace xxxxxx with your system-key
  // static String system_key = r"XXXXXXXXXXXXX";
  static String system_key = "neharika-tds";

  //Default language config
  static String default_language = "en";
  static String mobile_app_code = "en";
  static bool app_language_rtl = false;

  // configure this
  // localhost
  static const bool HTTPS = true;
  static const DOMAIN_PATH = "domain.com";

  // do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  // static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";
  // static const String BASE_URL = "https://neharika.3mtechbd.com/api/v2";
  static const String BASE_URL = "http://groceryandbutcher.shop/api/v2";

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }
}
