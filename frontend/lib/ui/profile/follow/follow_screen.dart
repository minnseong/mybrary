import 'package:flutter/material.dart';
import 'package:mybrary/data/model/profile/follower_response.dart';
import 'package:mybrary/data/model/profile/following_response.dart';
import 'package:mybrary/data/model/profile/profile_common_response.dart';
import 'package:mybrary/data/repository/follow_repository.dart';
import 'package:mybrary/res/constants/color.dart';
import 'package:mybrary/res/constants/enum.dart';
import 'package:mybrary/res/constants/style.dart';
import 'package:mybrary/ui/common/components/circular_loading.dart';
import 'package:mybrary/ui/common/components/single_data_error.dart';
import 'package:mybrary/ui/common/layout/subpage_layout.dart';
import 'package:mybrary/ui/profile/follow/components/follow_layout.dart';
import 'package:mybrary/ui/profile/follow/components/follow_user_info.dart';

class FollowScreen extends StatefulWidget {
  final String nickname;
  final FollowPageType pageType;

  const FollowScreen({
    required this.nickname,
    required this.pageType,
    super.key,
  });

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen>
    with TickerProviderStateMixin {
  late List<String> _followTabs = ['팔로워', '팔로잉'];

  Set<String> notFollowingUsers = {};

  bool isFollowing(String loginId) {
    return !notFollowingUsers.contains(loginId);
  }

  void onPressedAddFollowingUser(String loginId) {
    setState(() {
      if (isFollowing(loginId)) {
        notFollowingUsers.add(loginId);
      } else {
        notFollowingUsers.remove(loginId);
      }
    });
  }

  void onPressedDeleteFollowingUser(String loginId) {
    setState(() {
      notFollowingUsers.add(loginId);
    });
  }

  late final TabController _tabController = TabController(
    length: _followTabs.length,
    vsync: this,
  );

  final ScrollController _scrollController = ScrollController();
  final double _paddingTopHeight =
      Size.fromHeight(const SliverAppBar().toolbarHeight).height * 1.9;

  final _followRepository = FollowRepository();

  late Future<FollowerResponseData> _followerResponseData;
  late Future<FollowingResponseData> _followingResponseData;

  @override
  void initState() {
    super.initState();

    _followerResponseData = _followRepository.getFollower(
      userId: 'testId',
    );
    _followingResponseData = _followRepository.getFollowings(
      userId: 'testId',
    );

    if (widget.pageType == FollowPageType.follower) {
      _tabController.index = 0;
    }
    if (widget.pageType == FollowPageType.following) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: SubPageLayout(
        child: FutureBuilder<FollowCommonData>(
          future: Future.wait(futureFollowData()).then(
            (followData) => FollowCommonData(
              followerData: followData[0] as FollowerResponseData,
              followingData: followData[1] as FollowingResponseData,
            ),
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const SingleDataError(
                errorMessage: '팔로워 목록을 불러오는데 실패했습니다.',
              );
            }

            if (snapshot.hasData) {
              FollowCommonData data = snapshot.data!;
              final followers = data.followerData.followers!;
              final followings = data.followingData.followings!;

              _followTabs = <String>[
                '팔로워 ${followers.length}',
                '팔로잉 ${followings.length - notFollowingUsers.length}',
              ];

              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return followPageSliverBuilder(
                    context,
                    innerBoxIsScrolled,
                    _followTabs,
                    _tabController,
                  );
                },
                body: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    followerScreen(followers),
                    followingScreen(followings),
                  ],
                ),
              );
            }
            return const CircularLoading();
          },
        ),
      ),
    );
  }

  Padding followerScreen(List<Followers> followers) {
    return Padding(
      padding: EdgeInsets.only(top: _paddingTopHeight),
      child: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          Followers follower = followers[index];

          return FollowLayout(
            children: [
              FollowUserInfo(
                  nickname: follower.nickname!,
                  profileImageUrl: follower.profileImageUrl!),
              ElevatedButton(
                onPressed: () => onPressedDeleteFollowerUser(
                  context: context,
                  follower: follower,
                  followers: followers,
                  index: index,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: greyDDDDDD,
                  shape: followButtonRoundStyle,
                  minimumSize: const Size(60.0, 10.0),
                  splashFactory: NoSplash.splashFactory,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                child: const Text(
                  '삭제',
                  style: followButtonTextStyle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Padding followingScreen(List<Followings> followings) {
    return Padding(
      padding: EdgeInsets.only(top: _paddingTopHeight),
      child: ListView.builder(
        itemCount: followings.length,
        itemBuilder: (context, index) {
          Followings following = followings[index];
          String followingUserId = following.loginId!;

          return FollowLayout(
            children: [
              FollowUserInfo(
                nickname: following.nickname!,
                profileImageUrl: following.profileImageUrl!,
              ),
              ElevatedButton(
                onPressed: () => onPressedAddOrDeleteFollowingUser(
                  followingUserId: followingUserId,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      isFollowing(followingUserId) ? greyDDDDDD : primaryColor,
                  shape: followButtonRoundStyle,
                  minimumSize: const Size(60.0, 10.0),
                  splashFactory: NoSplash.splashFactory,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                child: Text(
                  isFollowing(followingUserId) ? '팔로잉' : '팔로우',
                  style: followButtonTextStyle.copyWith(
                    color: isFollowing(followingUserId)
                        ? commonBlackColor
                        : commonWhiteColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void onPressedDeleteFollowerUser({
    required BuildContext context,
    required Followers follower,
    required List<Followers> followers,
    required int index,
  }) async {
    await _followRepository.deleteFollower(
      userId: 'testId',
      sourceId: follower.loginId!,
    );

    if (!mounted) return;
    _showFollowButtonMessage(
      context: context,
      message: '삭제중',
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        followers.removeAt(index);
      });
      Navigator.of(context).pop();
    });
  }

  void onPressedAddOrDeleteFollowingUser({
    required String followingUserId,
  }) async {
    if (isFollowing(followingUserId)) {
      onPressedDeleteFollowingUser(followingUserId);
      await _followRepository.deleteFollowing(
        userId: 'testId',
        targetId: followingUserId,
      );
    } else {
      onPressedAddFollowingUser(followingUserId);
      await _followRepository.updateFollowing(
        userId: 'testId',
        targetId: followingUserId,
      );
    }
  }

  Future<dynamic> _showFollowButtonMessage({
    required BuildContext context,
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierColor: commonBlackColor.withOpacity(0.1),
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 76.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: grey262626.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                message,
                style: commonSubRegularStyle.copyWith(
                  color: commonWhiteColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Future<Object>> futureFollowData() => [
        _followerResponseData,
        _followingResponseData,
      ];

  List<Widget> followPageSliverBuilder(
    BuildContext context,
    bool innerBoxIsScrolled,
    List<String> followerTabs,
    TabController tabController,
  ) {
    return <Widget>[
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          elevation: 0,
          foregroundColor: commonBlackColor,
          backgroundColor: commonWhiteColor,
          // expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: commonWhiteColor,
            ),
          ),
          title: Text(widget.nickname),
          titleTextStyle: appBarTitleStyle.copyWith(
            fontSize: 16.0,
          ),
          centerTitle: true,
          pinned: true,
          expandedHeight: 104.01,
          forceElevated: innerBoxIsScrolled,
          bottom: followTabBar(
            tabController,
            followerTabs,
          ),
        ),
      ),
    ];
  }

  TabBar followTabBar(
    TabController tabController,
    List<String> followerTabs,
  ) {
    return TabBar(
      controller: tabController,
      indicatorColor: grey262626,
      labelColor: grey262626,
      labelStyle: commonButtonTextStyle,
      unselectedLabelColor: greyACACAC,
      unselectedLabelStyle: commonButtonTextStyle.copyWith(
        fontWeight: FontWeight.w400,
      ),
      tabs: followerTabs
          .map(
            (String name) => Tab(text: name),
          )
          .toList(),
    );
  }
}
