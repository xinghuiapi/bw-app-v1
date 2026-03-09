///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonEn common = TranslationsCommonEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn._(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'No Data'
	String get noData => 'No Data';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Select Language'
	String get languageSelectorTitle => 'Select Language';

	late final TranslationsCommonErrorEn error = TranslationsCommonErrorEn._(_root);
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Username'
	String get username => 'Username';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Login Success'
	String get loginSuccess => 'Login Success';

	/// en: 'Logged out safely'
	String get logoutSuccess => 'Logged out safely';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get title => 'Home';

	/// en: 'Activities'
	String get activities => 'Activities';

	/// en: 'Service'
	String get service => 'Service';

	/// en: 'Mine'
	String get mine => 'Mine';
}

// Path: common.error
class TranslationsCommonErrorEn {
	TranslationsCommonErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Connection timeout, please check your network'
	String get connectionTimeout => 'Connection timeout, please check your network';

	/// en: 'Send timeout, please try again'
	String get sendTimeout => 'Send timeout, please try again';

	/// en: 'Receive timeout, please try again later'
	String get receiveTimeout => 'Receive timeout, please try again later';

	/// en: 'Bad Request'
	String get badRequest => 'Bad Request';

	/// en: 'Unauthorized, please login again'
	String get unauthorized => 'Unauthorized, please login again';

	/// en: 'Forbidden'
	String get forbidden => 'Forbidden';

	/// en: 'Resource not found'
	String get notFound => 'Resource not found';

	/// en: 'Internal Server Error'
	String get serverError => 'Internal Server Error';

	/// en: 'Bad Gateway'
	String get badGateway => 'Bad Gateway';

	/// en: 'Service Unavailable'
	String get serviceUnavailable => 'Service Unavailable';

	/// en: 'Gateway Timeout'
	String get gatewayTimeout => 'Gateway Timeout';

	/// en: 'Network Error ({})'
	String get networkError => 'Network Error ({})';

	/// en: 'Request cancelled'
	String get cancelled => 'Request cancelled';

	/// en: 'Connection error, please check your network'
	String get connectionError => 'Connection error, please check your network';

	/// en: 'Unknown error, please try again'
	String get unknown => 'Unknown error, please try again';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.confirm' => 'Confirm',
			'common.cancel' => 'Cancel',
			'common.loading' => 'Loading...',
			'common.noData' => 'No Data',
			'common.retry' => 'Retry',
			'common.languageSelectorTitle' => 'Select Language',
			'common.error.connectionTimeout' => 'Connection timeout, please check your network',
			'common.error.sendTimeout' => 'Send timeout, please try again',
			'common.error.receiveTimeout' => 'Receive timeout, please try again later',
			'common.error.badRequest' => 'Bad Request',
			'common.error.unauthorized' => 'Unauthorized, please login again',
			'common.error.forbidden' => 'Forbidden',
			'common.error.notFound' => 'Resource not found',
			'common.error.serverError' => 'Internal Server Error',
			'common.error.badGateway' => 'Bad Gateway',
			'common.error.serviceUnavailable' => 'Service Unavailable',
			'common.error.gatewayTimeout' => 'Gateway Timeout',
			'common.error.networkError' => 'Network Error ({})',
			'common.error.cancelled' => 'Request cancelled',
			'common.error.connectionError' => 'Connection error, please check your network',
			'common.error.unknown' => 'Unknown error, please try again',
			'auth.login' => 'Login',
			'auth.register' => 'Register',
			'auth.logout' => 'Logout',
			'auth.username' => 'Username',
			'auth.password' => 'Password',
			'auth.loginSuccess' => 'Login Success',
			'auth.logoutSuccess' => 'Logged out safely',
			'home.title' => 'Home',
			'home.activities' => 'Activities',
			'home.service' => 'Service',
			'home.mine' => 'Mine',
			_ => null,
		};
	}
}
