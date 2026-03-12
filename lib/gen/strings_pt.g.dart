///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsPt with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsPt _root = this; // ignore: unused_field

	@override 
	TranslationsPt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPt(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonPt common = _TranslationsCommonPt._(_root);
	@override late final _TranslationsAuthPt auth = _TranslationsAuthPt._(_root);
	@override late final _TranslationsHomePt home = _TranslationsHomePt._(_root);
	@override late final _TranslationsTelegramLoginPt telegramLogin = _TranslationsTelegramLoginPt._(_root);
}

// Path: common
class _TranslationsCommonPt implements TranslationsCommonEn {
	_TranslationsCommonPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get confirm => 'Confirmar';
	@override String get cancel => 'Cancelar';
	@override String get loading => 'Carregando...';
	@override String get noData => 'Sem dados';
	@override String get retry => 'Tentar novamente';
	@override String get languageSelectorTitle => 'Selecionar idioma';
	@override late final _TranslationsCommonErrorPt error = _TranslationsCommonErrorPt._(_root);
}

// Path: auth
class _TranslationsAuthPt implements TranslationsAuthEn {
	_TranslationsAuthPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get login => 'Entrar';
	@override String get register => 'Registrar';
	@override String get logout => 'Sair';
	@override String get username => 'Nome de usuário';
	@override String get password => 'Senha';
	@override String get loginSuccess => 'Login com sucesso';
	@override String get logoutSuccess => 'Sair com segurança';
}

// Path: home
class _TranslationsHomePt implements TranslationsHomeEn {
	_TranslationsHomePt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Início';
	@override String get activities => 'Atividades';
	@override String get service => 'Serviço';
	@override String get mine => 'Meu';
}

// Path: telegramLogin
class _TranslationsTelegramLoginPt implements TranslationsTelegramLoginEn {
	_TranslationsTelegramLoginPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get firstLoginProcessing => 'Criando conta para você...';
	@override String get secureLoginProcessing => 'Fazendo login com segurança...';
	@override String passwordSetDefault({required Object password}) => 'Senha inicializada para ${password}, altere-a a tempo';
	@override String get setPasswordFailed => 'Falha ao definir a senha padrão, entre em contato com o suporte';
}

// Path: common.error
class _TranslationsCommonErrorPt implements TranslationsCommonErrorEn {
	_TranslationsCommonErrorPt._(this._root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get connectionTimeout => 'Tempo limite de conexão, verifique sua rede';
	@override String get sendTimeout => 'Tempo limite de envio, tente novamente';
	@override String get receiveTimeout => 'Tempo limite de recebimento, tente novamente mais tarde';
	@override String get badRequest => 'Solicitação incorreta';
	@override String get unauthorized => 'Não autorizado, faça login novamente';
	@override String get forbidden => 'Proibido';
	@override String get notFound => 'Recurso não encontrado';
	@override String get serverError => 'Erro interno do servidor';
	@override String get badGateway => 'Bad Gateway';
	@override String get serviceUnavailable => 'Serviço indisponível';
	@override String get gatewayTimeout => 'Gateway Timeout';
	@override String get networkError => 'Erro de rede ({})';
	@override String get cancelled => 'Solicitação cancelada';
	@override String get connectionError => 'Erro de conexão, verifique sua rede';
	@override String get unknown => 'Erro desconhecido, tente novamente';
}

/// The flat map containing all translations for locale <pt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.confirm' => 'Confirmar',
			'common.cancel' => 'Cancelar',
			'common.loading' => 'Carregando...',
			'common.noData' => 'Sem dados',
			'common.retry' => 'Tentar novamente',
			'common.languageSelectorTitle' => 'Selecionar idioma',
			'common.error.connectionTimeout' => 'Tempo limite de conexão, verifique sua rede',
			'common.error.sendTimeout' => 'Tempo limite de envio, tente novamente',
			'common.error.receiveTimeout' => 'Tempo limite de recebimento, tente novamente mais tarde',
			'common.error.badRequest' => 'Solicitação incorreta',
			'common.error.unauthorized' => 'Não autorizado, faça login novamente',
			'common.error.forbidden' => 'Proibido',
			'common.error.notFound' => 'Recurso não encontrado',
			'common.error.serverError' => 'Erro interno do servidor',
			'common.error.badGateway' => 'Bad Gateway',
			'common.error.serviceUnavailable' => 'Serviço indisponível',
			'common.error.gatewayTimeout' => 'Gateway Timeout',
			'common.error.networkError' => 'Erro de rede ({})',
			'common.error.cancelled' => 'Solicitação cancelada',
			'common.error.connectionError' => 'Erro de conexão, verifique sua rede',
			'common.error.unknown' => 'Erro desconhecido, tente novamente',
			'auth.login' => 'Entrar',
			'auth.register' => 'Registrar',
			'auth.logout' => 'Sair',
			'auth.username' => 'Nome de usuário',
			'auth.password' => 'Senha',
			'auth.loginSuccess' => 'Login com sucesso',
			'auth.logoutSuccess' => 'Sair com segurança',
			'home.title' => 'Início',
			'home.activities' => 'Atividades',
			'home.service' => 'Serviço',
			'home.mine' => 'Meu',
			'telegramLogin.firstLoginProcessing' => 'Criando conta para você...',
			'telegramLogin.secureLoginProcessing' => 'Fazendo login com segurança...',
			'telegramLogin.passwordSetDefault' => ({required Object password}) => 'Senha inicializada para ${password}, altere-a a tempo',
			'telegramLogin.setPasswordFailed' => 'Falha ao definir a senha padrão, entre em contato com o suporte',
			_ => null,
		};
	}
}
