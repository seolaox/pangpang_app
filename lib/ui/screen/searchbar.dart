import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final Function(String) onSearch;
  final Function() onShowFavorites;
  
  const SearchAppBar({
    super.key,
    required this.onSearch,
    required this.onShowFavorites,
  });

  @override
  ConsumerState<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends ConsumerState<SearchAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchMode = !_isSearchMode;
    });

    if (_isSearchMode) {
      _animationController.forward();
      // 약간의 딜레이 후 포커스 (애니메이션 완료 대기)
      Future.delayed(const Duration(milliseconds: 100), () {
        _searchFocusNode.requestFocus();
      });
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
      widget.onSearch(''); // 검색 초기화
    }
  }

  void _onSearchChanged(String query) {
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      title: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return _isSearchMode
              ? FadeTransition(
                  opacity: _animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: _buildSearchField(),
                  ),
                )
              : FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_animation),
                  child: const Text('동물병원 찾기'),
                );
        },
      ),
      actions: [
        // 검색 버튼
        IconButton(
          onPressed: _toggleSearch,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearchMode ? Icons.close : Icons.search,
              key: ValueKey(_isSearchMode),
            ),
          ),
          tooltip: _isSearchMode ? '검색 닫기' : '검색',
        ),
        
        // 즐겨찾기 버튼 (검색 모드가 아닐 때만 표시)
        if (!_isSearchMode) ...[
          IconButton(
            onPressed: widget.onShowFavorites,
            icon: const Icon(Icons.bookmark),
            tooltip: '즐겨찾기',
          ),
        ],
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: '동물병원 이름을 검색하세요',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}