import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/game_service.dart';
import '../../models/home_data.dart';
import '../../providers/game_launcher_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/web_safe_image.dart';
import '../../utils/constants.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<GameItem> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _handleSearch() async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await GameService.searchGames(keyword: keyword);
      if (response.isSuccess) {
        setState(() {
          _searchResults = response.data?.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.msg;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '搜索游戏...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _handleSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _handleSearch,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _searchResults.isEmpty
                  ? const Center(child: Text('没有找到相关游戏'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final game = _searchResults[index];
                        return _buildGameCard(game);
                      },
                    ),
    );
  }

  Widget _buildGameCard(GameItem game) {
    String imageUrl = game.img ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
    }

    return GestureDetector(
      onTap: () {
        ref.read(gameLauncherProvider).launchGame(
              context,
              game,
              isCategoryResult: game.isCategoryResult ?? false,
              isHot: game.isHot ?? false,
            );
      },
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: WebSafeImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: AppTheme.surface,
                  child: const Icon(Icons.gamepad, color: AppTheme.textTertiary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            game.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
