import 'package:flutter/material.dart';
import 'package:mybrary/res/colors/color.dart';

class SearchHeader extends StatelessWidget {
  final bool isSearching;
  final TextEditingController bookSearchController;
  final ValueChanged onSubmittedSearchKeyword;

  final VoidCallback onPressedIsbnScan;
  final VoidCallback onPressedTextClear;
  final VoidCallback onPressedSearchCancel;

  const SearchHeader({
    required this.isSearching,
    required this.bookSearchController,
    required this.onSubmittedSearchKeyword,
    required this.onPressedIsbnScan,
    required this.onPressedTextClear,
    required this.onPressedSearchCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final searchInputBorderStyle = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(5.0),
    );
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/screen', (route) => false);
          },
          icon: Icon(
            Icons.arrow_back,
            color: GREY_COLOR,
            size: 22.0,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: TextField(
              textInputAction: TextInputAction.search,
              controller: bookSearchController,
              cursorColor: PRIMARY_COLOR,
              onSubmitted: (value) => onSubmittedSearchKeyword(value),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                hintText: '책, 저자, 회원을 검색해보세요.',
                hintStyle: TextStyle(
                  fontSize: 14.0,
                ),
                filled: true,
                fillColor: GREY_COLOR_OPACITY_TWO,
                focusedBorder: searchInputBorderStyle,
                enabledBorder: searchInputBorderStyle,
                focusColor: GREY_COLOR,
                prefixIcon: Image.asset(
                  'assets/img/icon/search.png',
                  color: LESS_GREY_COLOR,
                  scale: 1.2,
                ),
                suffixIcon: IconButton(
                  onPressed: onPressedTextClear,
                  icon: Icon(
                    Icons.clear,
                    color: GREY_COLOR,
                    size: 22.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: onPressedIsbnScan,
              icon: Image.asset(
                'assets/img/icon/barcode_scan.png',
                color: PRIMARY_COLOR,
              ),
            ),
          )
        else
          TextButton(
            onPressed: onPressedSearchCancel,
            child: Text(
              '취소',
              style: TextStyle(
                color: DESCRIPTION_GREY_COLOR,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
      ],
    );
  }
}
