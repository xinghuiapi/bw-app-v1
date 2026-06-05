import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

class CountryDialOption {
  const CountryDialOption({
    required this.englishName,
    required this.myanmarName,
    required this.code,
  });

  final String englishName;
  final String myanmarName;
  final String code;

  String displayName(BuildContext context) {
    return context.locale.languageCode.toLowerCase() == 'my'
        ? myanmarName
        : englishName;
  }

  bool matches(String keyword, BuildContext context) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return code.contains(normalized) ||
        englishName.toLowerCase().contains(normalized) ||
        myanmarName.toLowerCase().contains(normalized);
  }
}

const countryDialOptions = <CountryDialOption>[
  CountryDialOption(englishName: 'China', myanmarName: 'တရုတ်', code: '+86'),
  CountryDialOption(
    englishName: 'Hong Kong, China',
    myanmarName: 'ဟောင်ကောင်၊ တရုတ်',
    code: '+852',
  ),
  CountryDialOption(
    englishName: 'Macau, China',
    myanmarName: 'မကာအို၊ တရုတ်',
    code: '+853',
  ),
  CountryDialOption(
    englishName: 'Taiwan, China',
    myanmarName: 'ထိုင်ဝမ်၊ တရုတ်',
    code: '+886',
  ),
  CountryDialOption(
    englishName: 'United States / Canada',
    myanmarName: 'အမေရိကန် / ကနေဒါ',
    code: '+1',
  ),
  CountryDialOption(englishName: 'Japan', myanmarName: 'ဂျပန်', code: '+81'),
  CountryDialOption(
    englishName: 'South Korea',
    myanmarName: 'တောင်ကိုရီးယား',
    code: '+82',
  ),
  CountryDialOption(
    englishName: 'United Kingdom',
    myanmarName: 'ယူနိုက်တက်ကင်းဒမ်း',
    code: '+44',
  ),
  CountryDialOption(
    englishName: 'Australia',
    myanmarName: 'ဩစတြေးလျ',
    code: '+61',
  ),
  CountryDialOption(
    englishName: 'Singapore',
    myanmarName: 'စင်ကာပူ',
    code: '+65',
  ),
  CountryDialOption(
    englishName: 'Malaysia',
    myanmarName: 'မလေးရှား',
    code: '+60',
  ),
  CountryDialOption(
    englishName: 'Thailand',
    myanmarName: 'ထိုင်း',
    code: '+66',
  ),
  CountryDialOption(englishName: 'France', myanmarName: 'ပြင်သစ်', code: '+33'),
  CountryDialOption(englishName: 'Germany', myanmarName: 'ဂျာမနီ', code: '+49'),
  CountryDialOption(englishName: 'Italy', myanmarName: 'အီတလီ', code: '+39'),
  CountryDialOption(englishName: 'Spain', myanmarName: 'စပိန်', code: '+34'),
  CountryDialOption(englishName: 'Russia', myanmarName: 'ရုရှား', code: '+7'),
  CountryDialOption(englishName: 'India', myanmarName: 'အိန္ဒိယ', code: '+91'),
];
