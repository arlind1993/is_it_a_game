enum LanguageTypes{
  Albanian,
  English,
}

class LanguageSupport {
  LanguageTypes languageType = LanguageTypes.English;

  final Map<LanguageTypes, Map<String,String>> _allErrorMessages = {
    LanguageTypes.Albanian: {
      "no_internet_error": "Nuk mund te lidheni, nuk ka internet!"
    },
    LanguageTypes.English: {
      "no_internet_error": "You cannot be connected, there is no internet!"
    }
  };

  final Map<LanguageTypes, Map<String, String>> _allStrings = {
    LanguageTypes.Albanian:{

    },
    LanguageTypes.English:{

    }
  };

  Map<String, String> get errorMessages => _allErrorMessages[languageType]!;
  Map<String, String> get strings => _allStrings[languageType]!;

  setLanguage(LanguageTypes languageType){
    this.languageType=languageType;
  }
}