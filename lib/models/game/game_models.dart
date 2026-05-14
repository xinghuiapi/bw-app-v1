import '../core/json_utils.dart';

class GameCategory {
  final int id;
  final String? title;
  final String? img;
  final String? selectedImg;
  final String? code;
  final List<GameSubCategory> subCategories;

  const GameCategory({
    required this.id,
    this.title,
    this.img,
    this.selectedImg,
    this.code,
    this.subCategories = const [],
  });

  factory GameCategory.fromJson(Map<String, dynamic> json) => GameCategory(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        img: jsonString(json['img']),
        selectedImg: jsonString(json['se_img']),
        code: jsonString(json['code']),
        subCategories: jsonList(
          json['sub'] ?? json['children'] ?? json['list'],
          GameSubCategory.fromJson,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (img != null) 'img': img,
        if (selectedImg != null) 'se_img': selectedImg,
        if (code != null) 'code': code,
        'sub': subCategories.map((item) => item.toJson()).toList(),
      };
}

class GameProviderItem {
  final int id;
  final String code;
  final String title;
  final int category;
  final int status;
  final String? logo;
  final String? type;
  final dynamic label;

  const GameProviderItem({
    required this.id,
    required this.code,
    required this.title,
    this.category = 0,
    this.status = 1,
    this.logo,
    this.type,
    this.label,
  });

  factory GameProviderItem.fromJson(Map<String, dynamic> json) {
    return GameProviderItem(
      id: jsonInt(json['id']) ?? 0,
      code: jsonString(json['code'])?.trim() ?? '',
      title: jsonString(json['title']) ?? '',
      category: jsonInt(json['category']) ?? 0,
      status: jsonInt(json['status_s'] ?? json['status']) ?? 1,
      logo: jsonString(json['h5_logo'] ?? json['img'])?.trim(),
      type: jsonString(json['type'])?.trim(),
      label: json['label'],
    );
  }

  bool get isMaintaining => status == 0;
  bool get opensSubList => category == 1;

  GameLaunchTarget get launchTarget => GameLaunchTarget(id: id, title: title);
}

class GameLobbyCategory {
  final int id;
  final String title;
  final String code;
  final String? img;
  final String? selectedImg;
  final List<GameProviderItem> games;

  const GameLobbyCategory({
    required this.id,
    required this.title,
    required this.code,
    this.img,
    this.selectedImg,
    this.games = const [],
  });

  factory GameLobbyCategory.fromJson(Map<String, dynamic> json) {
    return GameLobbyCategory(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title']) ?? '',
      code: jsonString(json['code'])?.trim() ?? '',
      img: jsonString(json['img'])?.trim(),
      selectedImg: jsonString(json['se_img'])?.trim(),
    );
  }

  GameLobbyCategory copyWith({List<GameProviderItem>? games}) {
    return GameLobbyCategory(
      id: id,
      title: title,
      code: code,
      img: img,
      selectedImg: selectedImg,
      games: games ?? this.games,
    );
  }
}

class GameSubCategory {
  final int id;
  final String? title;
  final String? h5Logo;
  final String? pcLogo;
  final String? gameCode;
  final int? category;
  final int? status;
  final String? img;
  final String? label;

  const GameSubCategory({
    required this.id,
    this.title,
    this.h5Logo,
    this.pcLogo,
    this.gameCode,
    this.category,
    this.status,
    this.img,
    this.label,
  });

  factory GameSubCategory.fromJson(Map<String, dynamic> json) {
    return GameSubCategory(
      id: jsonInt(json['id']) ?? 0,
      title: jsonString(json['title']),
      h5Logo: jsonString(json['h5_logo']),
      pcLogo: jsonString(json['pc_logo']),
      gameCode:
          jsonString(json['gamecode'] ?? json['game_code'] ?? json['code']),
      category: jsonInt(json['category']),
      status: jsonInt(json['status_s'] ?? json['status']),
      img: jsonString(json['img']),
      label: jsonString(json['label']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (h5Logo != null) 'h5_logo': h5Logo,
        if (pcLogo != null) 'pc_logo': pcLogo,
        if (gameCode != null) 'game_code': gameCode,
        if (category != null) 'category': category,
        if (status != null) 'status_s': status,
        if (img != null) 'img': img,
        if (label != null) 'label': label,
      };
}

class GameItem {
  final int id;
  final String? title;
  final String? img;
  final String? gameCode;
  final dynamic favorites;
  final bool? isCategoryResult;
  final bool? isHot;
  final String? interfaceTitle;
  final List<String> labels;
  final int status;
  final bool favorited;

  const GameItem({
    required this.id,
    this.title,
    this.img,
    this.gameCode,
    this.favorites,
    this.isCategoryResult,
    this.isHot,
    this.interfaceTitle,
    this.labels = const [],
    this.status = 1,
    this.favorited = false,
  });

  factory GameItem.fromJson(Map<String, dynamic> json) => GameItem(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        img: jsonString(json['h5_logo'] ?? json['img'])?.trim(),
        gameCode: jsonString(json['game_code'] ?? json['code']),
        favorites: json['favorites'],
        isCategoryResult: jsonBool(json['is_category_result']),
        isHot: jsonBool(json['is_hot']),
        interfaceTitle: jsonString(json['interface_title']),
        status: jsonInt(json['status_s'] ?? json['status']) ?? 1,
        favorited: jsonBool(json['favorite'] ??
                json['is_favorite'] ??
                json['fav'] ??
                json['collect'] ??
                json['is_collect'] ??
                json['favorite_status'] ??
                json['collect_status'] ??
                json['favorites']) ??
            false,
        labels: json['label'] is List
            ? (json['label'] as List).map((item) => item.toString()).toList()
            : const [],
      );

  bool get isFavorite => favorited;
  bool get isMaintaining => status == 0;
  GameLaunchTarget get launchTarget =>
      GameLaunchTarget(id: id, title: title ?? '');

  GameItem copyWith({bool? favorited}) {
    return GameItem(
      id: id,
      title: title,
      img: img,
      gameCode: gameCode,
      favorites: favorites,
      isCategoryResult: isCategoryResult,
      isHot: isHot,
      interfaceTitle: interfaceTitle,
      labels: labels,
      status: status,
      favorited: favorited ?? this.favorited,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (img != null) 'img': img,
        if (gameCode != null) 'game_code': gameCode,
        if (favorites != null) 'favorites': favorites,
        if (isCategoryResult != null) 'is_category_result': isCategoryResult,
        if (isHot != null) 'is_hot': isHot,
        if (interfaceTitle != null) 'interface_title': interfaceTitle,
        'status_s': status,
        'favorite': favorited,
        'label': labels,
      };
}

class RecommendedGame {
  final int id;
  final String code;
  final String game;
  final String? gameCode;
  final String title;
  final String? img;
  final dynamic label;
  final String? type;
  final int category;
  final int status;
  final bool favorited;

  const RecommendedGame({
    required this.id,
    required this.code,
    required this.game,
    this.gameCode,
    required this.title,
    this.img,
    this.label,
    this.type,
    this.category = 0,
    this.status = 1,
    this.favorited = false,
  });

  factory RecommendedGame.fromJson(Map<String, dynamic> json) {
    return RecommendedGame(
      id: jsonInt(json['id']) ?? 0,
      code: jsonString(json['code'])?.trim() ?? '',
      game: jsonString(json['game'] ?? json['gamecode'] ?? json['game_code'])
              ?.trim() ??
          '',
      gameCode: jsonString(json['gamecode'] ?? json['game_code'])?.trim(),
      title: jsonString(json['title']) ?? '',
      img: jsonString(json['h5_logo'] ?? json['img'])?.trim(),
      label: json['label'],
      type: jsonString(json['type'])?.trim(),
      category: jsonInt(json['category']) ?? 0,
      status: jsonInt(json['status_s'] ?? json['status']) ?? 1,
      favorited: jsonBool(json['favorite'] ??
              json['is_favorite'] ??
              json['fav'] ??
              json['collect'] ??
              json['is_collect'] ??
              json['favorite_status'] ??
              json['collect_status'] ??
              json['favorites']) ??
          false,
    );
  }

  bool get isMaintaining => status == 0;
  bool get opensSubList => category == 1;
  String get subListCode =>
      type?.trim().isNotEmpty == true ? type!.trim() : code;
  String get subListGame => code.trim().isNotEmpty ? code.trim() : game.trim();

  GameLaunchTarget get launchTarget => GameLaunchTarget(id: id, title: title);

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'game': game,
        if (gameCode != null) 'gamecode': gameCode,
        'title': title,
        if (img != null) 'img': img,
        if (label != null) 'label': label,
        if (type != null) 'type': type,
        'category': category,
        'status_s': status,
        'favorites': favorited,
      };
}

class GameListPage {
  final List<GameItem> data;
  final int? currentPage;
  final int? total;
  final int? lastPage;

  const GameListPage({
    this.data = const [],
    this.currentPage,
    this.total,
    this.lastPage,
  });

  GameListPage copyWith({
    List<GameItem>? data,
    int? currentPage,
    int? total,
    int? lastPage,
  }) {
    return GameListPage(
      data: data ?? this.data,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  factory GameListPage.fromJson(Map<String, dynamic> json) => GameListPage(
        data: jsonList(json['data'], GameItem.fromJson),
        currentPage: jsonInt(json['current_page']),
        total: jsonInt(json['total']),
        lastPage: jsonInt(json['lastPage'] ?? json['last_page']),
      );

  Map<String, dynamic> toJson() => {
        'data': data.map((item) => item.toJson()).toList(),
        if (currentPage != null) 'current_page': currentPage,
        if (total != null) 'total': total,
        if (lastPage != null) 'lastPage': lastPage,
      };
}

class GameLaunchResult {
  final String? url;
  final bool nesting;

  const GameLaunchResult({this.url, this.nesting = true});

  factory GameLaunchResult.fromJson(Map<String, dynamic> json) {
    return GameLaunchResult(
      url: jsonString(json['url'] ?? json['game_url']),
      nesting: jsonBool(json['nesting']) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (url != null) 'url': url,
        'nesting': nesting,
      };
}

class GameLaunchTarget {
  final int id;
  final String title;

  const GameLaunchTarget({required this.id, required this.title});
}

class GameBalance {
  final int id;
  final dynamic money;
  final String? title;
  final String? code;

  const GameBalance({required this.id, this.money, this.title, this.code});

  factory GameBalance.fromJson(Map<String, dynamic> json) => GameBalance(
        id: jsonInt(json['id']) ?? 0,
        money: json['money'] ?? json['balance'],
        title: jsonString(json['title']),
        code: jsonString(json['code']),
      );

  double get balance => jsonDouble(money) ?? 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (money != null) 'money': money,
        if (title != null) 'title': title,
        if (code != null) 'code': code,
      };
}
