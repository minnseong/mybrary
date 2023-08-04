import 'package:flutter/material.dart';
import 'package:mybrary/data/model/profile/interest_categories_response.dart';
import 'package:mybrary/data/model/profile/my_interests_response.dart';
import 'package:mybrary/data/repository/interests_repository.dart';
import 'package:mybrary/res/constants/style.dart';
import 'package:mybrary/ui/common/components/circular_loading.dart';
import 'package:mybrary/ui/common/layout/subpage_layout.dart';
import 'package:mybrary/ui/profile/my_interests/components/interest_category.dart';
import 'package:mybrary/ui/profile/my_interests/components/interest_description.dart';
import 'package:mybrary/ui/profile/my_interests/components/recommend_phrase.dart';

class MyInterestsScreen extends StatefulWidget {
  final List<UserInterests> userInterests;

  const MyInterestsScreen({
    required this.userInterests,
    super.key,
  });

  @override
  State<MyInterestsScreen> createState() => _MyInterestsScreenState();
}

class _MyInterestsScreenState extends State<MyInterestsScreen> {
  late List<CategoriesResponses> selectedInterests;

  final InterestsRepository _interestsRepository = InterestsRepository();
  late Future<InterestCategoriesResponseData> _interestCategoriesResponseData;

  @override
  void initState() {
    super.initState();

    _interestCategoriesResponseData =
        _interestsRepository.getInterestCategories();

    selectedInterests = widget.userInterests
        .map((e) => CategoriesResponses(id: e.id, name: e.name))
        .toList();
  }

  void _onSelectedInterest(int index, String name) {
    setState(() {
      if (selectedInterests.any((category) => category.id == index)) {
        return selectedInterests
            .removeWhere((category) => category.id == index);
      }

      if (selectedInterests.length > 2) {
        selectedInterests.remove(selectedInterests.first);
      }

      selectedInterests.add(
        CategoriesResponses(id: index, name: name),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      appBarTitle: '마이 관심사',
      appBarActions: [
        TextButton(
          onPressed: () async {
            await _interestsRepository.editMyInterests(
              userId: 'testId',
              categoriesResponses: selectedInterests,
            );

            if (!mounted) return;
            _showMyInterestsSavedMessage(
              context: context,
              snackBarText: '마이 관심사가 저장되었습니다.',
            );
            Navigator.pop(context);
          },
          style: disableAnimationButtonStyle,
          child: const Text(
            '저장',
            style: saveTextButtonStyle,
          ),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraint.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    const RecommendPhrase(),
                    const SizedBox(height: 16.0),
                    FutureBuilder<InterestCategoriesResponseData>(
                      future: _interestCategoriesResponseData,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final interestCategories =
                              snapshot.data!.interestCategories!;

                          return interestCategoriesList(
                            interestCategories: interestCategories,
                          );
                        }
                        return const CircularLoading();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMyInterestsSavedMessage({
    required BuildContext context,
    required String snackBarText,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarText),
        duration: const Duration(
          seconds: 1,
        ),
      ),
    );
  }

  Column interestCategoriesList({
    required List<InterestCategories> interestCategories,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: interestCategories.map(
        (e) {
          final int startIndex = e.description!.indexOf(e.name!);
          final int endIndex = startIndex + e.name!.length;

          Widget description = InterestDescription(
            description: e.description!,
            startIndex: startIndex,
            endIndex: endIndex,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              description,
              const SizedBox(height: 12.0),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: e.interestResponses!.map(
                  (e) {
                    final bool isSelected = selectedInterests.any(
                      (category) => category.id == e.id,
                    );

                    return InkWell(
                      onTap: () => _onSelectedInterest(
                        e.id!,
                        e.name!,
                      ),
                      child: InterestCategory(
                        isSelected: isSelected,
                        name: e.name!,
                      ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 32.0),
            ],
          );
        },
      ).toList(),
    );
  }
}
