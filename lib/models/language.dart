
class Language {
  String name, flag, languageCode;
  int id;

  Language({ this.name, this.flag, this.languageCode, this.id });

  static List<Language> languageList() {
    return <Language> [
      Language(
        name: "English",
        flag: "🇺🇸",
        languageCode: "en",
        id: 1
      ),
       Language(
        name: "Spanish",
        flag: "🇲🇽",
        languageCode: "es",
        id: 2
      ),
    ];
  }



}