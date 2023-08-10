package kr.mybrary.bookservice.review.domain;

import static org.assertj.core.api.Assertions.*;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assertions.assertAll;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.never;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;

import java.util.Optional;
import kr.mybrary.bookservice.mybook.MyBookFixture;
import kr.mybrary.bookservice.mybook.domain.MyBookService;
import kr.mybrary.bookservice.mybook.persistence.MyBook;
import kr.mybrary.bookservice.review.MyBookReviewDtoTestData;
import kr.mybrary.bookservice.review.MyBookReviewFixture;
import kr.mybrary.bookservice.review.domain.dto.request.MyReviewCreateServiceRequest;
import kr.mybrary.bookservice.review.domain.dto.request.MyReviewUpdateServiceRequest;
import kr.mybrary.bookservice.review.domain.exception.MyReviewAccessDeniedException;
import kr.mybrary.bookservice.review.domain.exception.MyReviewAlreadyExistsException;
import kr.mybrary.bookservice.review.persistence.MyReview;
import kr.mybrary.bookservice.review.persistence.repository.MyReviewRepository;
import kr.mybrary.bookservice.review.presentation.dto.response.MyReviewUpdateResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.context.ActiveProfiles;

@ActiveProfiles("test")
@ExtendWith(MockitoExtension.class)
class MyReviewWriteServiceTest {

    @InjectMocks
    private MyReviewWriteService myReviewWriteService;

    @Mock
    private MyReviewRepository myBookReviewRepository;

    @Mock
    private MyBookService myBookService;

    @DisplayName("마이북 리뷰를 등록한다.")
    @Test
    void create() {

        // given
        MyReviewCreateServiceRequest request = MyBookReviewDtoTestData.createMyBookReviewCreateServiceRequest();
        MyBook myBook = MyBookFixture.COMMON_LOGIN_USER_MYBOOK.getMyBook();

        given(myBookService.findMyBookByIdWithBook(request.getMyBookId())).willReturn(myBook);
        given(myBookReviewRepository.existsByMyBook(myBook)).willReturn(false);
        given(myBookReviewRepository.save(any())).willReturn(any());

        // when
        myReviewWriteService.create(request);

        // then
        assertAll(
                () -> verify(myBookService, times(1)).findMyBookByIdWithBook(request.getMyBookId()),
                () -> verify(myBookReviewRepository, times(1)).existsByMyBook(myBook),
                () -> verify(myBookReviewRepository, times(1)).save(any())
        );
    }

    @DisplayName("다른 유저의 마이북 리뷰를 등록할 시, 예외가 발생한다.")
    @Test
    void occurExceptionWhenWriteOtherBookReview() {

        // given
        MyReviewCreateServiceRequest request = MyBookReviewDtoTestData.createMyBookReviewCreateServiceRequest();
        MyBook myBook = MyBookFixture.COMMON_OTHER_USER_MYBOOK.getMyBook();

        given(myBookService.findMyBookByIdWithBook(request.getMyBookId())).willReturn(myBook);

        // when, then
        assertAll(
                () -> assertThatThrownBy(() -> myReviewWriteService.create(request))
                        .isInstanceOf(MyReviewAccessDeniedException.class),
                () -> verify(myBookService, times(1)).findMyBookByIdWithBook(request.getMyBookId()),
                () -> verify(myBookReviewRepository, never()).existsByMyBook(myBook),
                () -> verify(myBookReviewRepository, never()).save(any())
        );
    }

    @DisplayName("마이북에 등록된 리뷰가 있으면 예외가 발생한다.")
    @Test
    void occurExceptionWhenExistMyBookReview() {

        // given
        MyReviewCreateServiceRequest request = MyBookReviewDtoTestData.createMyBookReviewCreateServiceRequest();
        MyBook myBook = MyBookFixture.COMMON_LOGIN_USER_MYBOOK.getMyBook();

        given(myBookService.findMyBookByIdWithBook(request.getMyBookId())).willReturn(myBook);
        given(myBookReviewRepository.existsByMyBook(myBook)).willReturn(true);

        // when, then
        assertAll(
                () -> assertThatThrownBy(() -> myReviewWriteService.create(request))
                        .isInstanceOf(MyReviewAlreadyExistsException.class),
                () -> verify(myBookService, times(1)).findMyBookByIdWithBook(request.getMyBookId()),
                () -> verify(myBookReviewRepository, times(1)).existsByMyBook(myBook),
                () -> verify(myBookReviewRepository, never()).save(any())
        );
    }

    @DisplayName("마이 리뷰를 수정한다.")
    @Test
    void updateMyReview() {

        // given
        MyReview myReview = MyBookReviewFixture.COMMON_MY_BOOK_REVIEW.getMyBookReviewBuilder()
                .myBook(MyBookFixture.COMMON_LOGIN_USER_MYBOOK.getMyBook()).build();
        MyReviewUpdateServiceRequest request = MyBookReviewDtoTestData.createMyReviewUpdateServiceRequest(
                myReview.getMyBook().getUserId(), myReview.getId());

        given(myBookReviewRepository.findById(any())).willReturn(Optional.of(myReview));

        // when
        MyReviewUpdateResponse response = myReviewWriteService.update(request);

        // then
        assertAll(
                () -> verify(myBookReviewRepository, times(1)).findById(any()),
                () -> assertThat(response.getId()).isEqualTo(myReview.getId()),
                () -> assertThat(response.getContent()).isEqualTo(myReview.getContent()),
                () -> assertThat(response.getStarRating()).isEqualTo(myReview.getStarRating())
        );
    }

    @DisplayName("다른 유저의 마이 리뷰를 수정시, 예외가 발생한다.")
    @Test
    void occurExceptionWhenUpdateOtherBookReview() {

        // given
        MyReview myReview = MyBookReviewFixture.COMMON_MY_BOOK_REVIEW.getMyBookReviewBuilder()
                .myBook(MyBookFixture.COMMON_LOGIN_USER_MYBOOK.getMyBook()).build();
        MyReviewUpdateServiceRequest request = MyBookReviewDtoTestData.createMyReviewUpdateServiceRequest(
                "OTHER_LOGIN_ID", myReview.getId());

        given(myBookReviewRepository.findById(any())).willReturn(Optional.of(myReview));

        // when, then
        assertAll(
                () -> assertThatThrownBy(() -> myReviewWriteService.update(request)).isInstanceOf(MyReviewAccessDeniedException.class),
                () -> verify(myBookReviewRepository, times(1)).findById(any()),
                () -> assertThat(myReview.getContent()).isNotEqualTo(request.getContent()),
                () -> assertThat(myReview.getStarRating()).isNotEqualTo(request.getStarRating())
        );
    }
}