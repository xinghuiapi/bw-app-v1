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
class TranslationsZh with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsZh _root = this; // ignore: unused_field

	@override 
	TranslationsZh $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZh(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonZh common = _TranslationsCommonZh._(_root);
	@override late final _TranslationsAuthZh auth = _TranslationsAuthZh._(_root);
	@override late final _TranslationsHomeZh home = _TranslationsHomeZh._(_root);
	@override late final _TranslationsTelegramLoginZh telegramLogin = _TranslationsTelegramLoginZh._(_root);
}

// Path: common
class _TranslationsCommonZh implements TranslationsCommonEn {
	_TranslationsCommonZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get confirm => '确定';
	@override String get cancel => '取消';
	@override String get loading => '加载中...';
	@override String get noData => '暂无数据';
	@override String get retry => '重试';
	@override String get languageSelectorTitle => '选择语言';
	@override late final _TranslationsCommonErrorZh error = _TranslationsCommonErrorZh._(_root);
}

// Path: auth
class _TranslationsAuthZh implements TranslationsAuthEn {
	_TranslationsAuthZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get login => '登录';
	@override String get register => '注册';
	@override String get logout => '退出登录';
	@override String get username => '用户名';
	@override String get password => '密码';
	@override String get loginSuccess => '登录成功';
	@override String get logoutSuccess => '已安全退出';
}

// Path: home
class _TranslationsHomeZh implements TranslationsHomeEn {
	_TranslationsHomeZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '首页';
	@override String get activities => '活动';
	@override String get service => '客服';
	@override String get mine => '我的';
}

// Path: telegramLogin
class _TranslationsTelegramLoginZh implements TranslationsTelegramLoginEn {
	_TranslationsTelegramLoginZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get firstLoginProcessing => '正在为您创建账户...';
	@override String get secureLoginProcessing => '正在安全登录中...';
	@override String passwordSetDefault({required Object password}) => '密码已初始化为 ${password}，请及时修改';
	@override String get setPasswordFailed => '设置默认密码失败，请联系客服';
}

// Path: common.error
class _TranslationsCommonErrorZh implements TranslationsCommonErrorEn {
	_TranslationsCommonErrorZh._(this._root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get connectionTimeout => '连接服务器超时，请检查网络设置';
	@override String get sendTimeout => '请求发送超时，请重试';
	@override String get receiveTimeout => '服务器响应超时，请稍后重试';
	@override String get badRequest => '错误请求';
	@override String get unauthorized => '未授权，请重新登录';
	@override String get forbidden => '拒绝访问';
	@override String get notFound => '请求资源不存在';
	@override String get serverError => '服务器内部错误';
	@override String get badGateway => '网关错误';
	@override String get serviceUnavailable => '服务不可用';
	@override String get gatewayTimeout => '网关超时';
	@override String get networkError => '网络请求错误 ({})';
	@override String get cancelled => '请求已取消';
	@override String get connectionError => '网络连接失败，请检查网络';
	@override String get unknown => '未知错误，请重试';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZh {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.confirm' => '确定',
			'common.cancel' => '取消',
			'common.loading' => '加载中...',
			'common.noData' => '暂无数据',
			'common.retry' => '重试',
			'common.languageSelectorTitle' => '选择语言',
			'common.error.connectionTimeout' => '连接服务器超时，请检查网络设置',
			'common.error.sendTimeout' => '请求发送超时，请重试',
			'common.error.receiveTimeout' => '服务器响应超时，请稍后重试',
			'common.error.badRequest' => '错误请求',
			'common.error.unauthorized' => '未授权，请重新登录',
			'common.error.forbidden' => '拒绝访问',
			'common.error.notFound' => '请求资源不存在',
			'common.error.serverError' => '服务器内部错误',
			'common.error.badGateway' => '网关错误',
			'common.error.serviceUnavailable' => '服务不可用',
			'common.error.gatewayTimeout' => '网关超时',
			'common.error.networkError' => '网络请求错误 ({})',
			'common.error.cancelled' => '请求已取消',
			'common.error.connectionError' => '网络连接失败，请检查网络',
			'common.error.unknown' => '未知错误，请重试',
			'auth.login' => '登录',
			'auth.register' => '注册',
			'auth.logout' => '退出登录',
			'auth.username' => '用户名',
			'auth.password' => '密码',
			'auth.loginSuccess' => '登录成功',
			'auth.logoutSuccess' => '已安全退出',
			'home.title' => '首页',
			'home.activities' => '活动',
			'home.service' => '客服',
			'home.mine' => '我的',
			'telegramLogin.firstLoginProcessing' => '正在为您创建账户...',
			'telegramLogin.secureLoginProcessing' => '正在安全登录中...',
			'telegramLogin.passwordSetDefault' => ({required Object password}) => '密码已初始化为 ${password}，请及时修改',
			'telegramLogin.setPasswordFailed' => '设置默认密码失败，请联系客服',
			_ => null,
		};
	}
}
