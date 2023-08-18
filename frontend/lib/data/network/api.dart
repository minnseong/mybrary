import 'dart:developer';

import 'package:dio/dio.dart';

const mybraryUrl = "http://mybrary.kr";
const mybraryUrlScheme = "kr.mybrary";
const baseUrl = "$mybraryUrl:8000";
const bookServiceUrl = "$mybraryUrl:8000";

enum API {
  // oauth
  naverLogin,
  kakaoLogin,
  googleLogin,
  getRefreshToken,
  // user-service
  getUserProfile,
  getUserProfileImage,
  getUserFollowers,
  getUserFollowings,
  getUserInterests,
  getInterestCategories,
  updateUserProfile,
  updateUserProfileImage,
  updateUserFollowing,
  updateUserInterests,
  deleteUserProfileImage,
  deleteUserFollower,
  deleteUserFollowing,
  deleteUserAccount,
  // book-service search
  getBookService,
  getBookSearchKeyword,
  getBookSearchDetail,
  getBookSearchDetailReviews,
  getMyBooks,
  getMyBookDetail,
  getMyBookReview,
  getInterestBooks,
  getTodayRegisteredBookCount,
  getBookListByCategory,
  createMyBook,
  createMyBookReview,
  createOrDeleteInterestBook,
  updateMyBookRecord,
  updateMyBookReview,
  deleteMyBook,
}

Map<API, String> apiMap = {
  // oauth
  API.naverLogin: "/user-service/oauth2/authorization/naver",
  API.kakaoLogin: "/user-service/oauth2/authorization/kakao",
  API.googleLogin: "/user-service/oauth2/authorization/google",
  API.getRefreshToken: "/user-service/auth/v1/refresh",
  // user-service
  API.getUserProfile: "/user-service/api/v1/users", // /{userId}/profile",
  API.getUserProfileImage:
      "/user-service/api/v1/users", // /{userId}/profile/image",
  API.getUserFollowers: "/user-service/api/v1/users", // /{userId}/followers",
  API.getUserFollowings: "/user-service/api/v1/users", // /{userId}/followings",
  API.getUserInterests: "/user-service/api/v1/users", // '/{userId}/interests'
  API.getInterestCategories: "/user-service/api/v1/interest-categories",
  API.updateUserProfile: "/user-service/api/v1/users", // /{userId}/profile",
  API.updateUserProfileImage:
      "/user-service/api/v1/users", // /{userId}/profile/image",
  API.updateUserFollowing: "/user-service/api/v1/users/follow",
  API.updateUserInterests:
      "/user-service/api/v1/users", // '/{userId}/interests'
  API.deleteUserProfileImage:
      "/user-service/api/v1/users", // /{userId}/profile/image",
  API.deleteUserFollower: "/user-service/api/v1/users/follower",
  API.deleteUserFollowing: "/user-service/api/v1/users/follow",
  API.deleteUserAccount: "/user-service/api/v1/users/account",
  // book-service
  API.getBookService: "/book-service/api/v1",
  API.getBookSearchKeyword: "/book-service/api/v1/books/search",
  API.getBookSearchDetail: "/book-service/api/v1/books/detail",
  API.getBookSearchDetailReviews:
      "/book-service/api/v1/books", // '/{isbn13}/reviews'
  API.getMyBooks: "/book-service/api/v1/users", // '/{userId}/mybooks'
  API.getMyBookDetail: "/book-service/api/v1/mybooks", // '/{mybookId}'
  API.getMyBookReview: "/book-service/api/v1/mybooks", // '/{mybookId}/review'
  API.getInterestBooks:
      "/book-service/api/v1/books/users", // '/{userId}/interest'
  API.getTodayRegisteredBookCount:
      "/book-service/api/v1/mybooks/today-registration-count",
  API.getBookListByCategory:
      "/book-service/api/v1/books/search/book-list-by-category",
  API.createMyBook: "/book-service/api/v1/mybooks",
  API.createMyBookReview:
      "/book-service/api/v1/mybooks", // '/{mybookId}/reviews'
  API.createOrDeleteInterestBook:
      "/book-service/api/v1/books", // '/{isbn13}/interest'
  API.updateMyBookRecord: "/book-service/api/v1/mybooks", // '/{mybookId}'
  API.updateMyBookReview: "/book-service/api/v1/reviews", // '/{reviewId}'
  API.deleteMyBook: "/book-service/api/v1/mybooks", // '/{mybookId}'
};

String getApi(API apiType) {
  String api = baseUrl;
  api += apiMap[apiType]!;
  return api;
}

String getBookServiceApi(API apiType) {
  String api = bookServiceUrl;
  api += apiMap[apiType]!;
  return api;
}

commonResponseResult(
  Response<dynamic> response,
  Function successCallback,
) {
  try {
    switch (response.statusCode) {
      case 200 || 201:
        return successCallback();
      case 404:
        log('ERROR: 서버에 404 에러가 있습니다.');
        return response.data;
      default:
        log('ERROR: 서버의 API 호출에 실패했습니다.');
        throw Exception('서버의 API 호출에 실패했습니다.');
    }
  } on DioException catch (error) {
    if (error.response != null) {
      throw Exception('${error.response!.data['errorMessage']}');
    }
    throw Exception('서버 요청에 실패했습니다.');
  }
}
