package kr.mybrary.bookservice.book.domain;

import java.util.List;
import kr.mybrary.bookservice.book.domain.dto.BookDtoMapper;
import kr.mybrary.bookservice.book.domain.dto.BookSearchResultDto;
import kr.mybrary.bookservice.book.domain.dto.kakaoapi.Document;
import kr.mybrary.bookservice.book.domain.dto.kakaoapi.KakaoBookSearchResponse;
import kr.mybrary.bookservice.book.domain.exception.BookSearchResultNotFoundException;
import kr.mybrary.bookservice.book.presentation.dto.response.BookSearchResultResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
@RequiredArgsConstructor
public class KakaoBookSearchApiService implements PlatformBookSearchApiService {

    private final RestTemplate restTemplate;

    @Value("${kakao.api.key}")
    private String API_KEY;

    private static final String API_URL_WITH_KEYWORD = "https://dapi.kakao.com/v3/search/book?query=%s&sort=%s&page=%d";
    private static final String API_URL_WITH_ISBN = "https://dapi.kakao.com/v3/search/book?target=isbn&query=%s&sort=%s&page=%d";
    private static final String REQUEST_NEXT_URL = "/books/search?keyword=%s&sort=%s&page=%d";
    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String KAKAO_AUTHORIZATION_HEADER_PREFIX = "KakaoAK ";

    @Override
    public BookSearchResultResponse searchWithKeyword(String keyword, String sort, int page) {
        return searchBookFromKakaoApi(API_URL_WITH_KEYWORD, keyword, sort, page);
    }

    @Override
    public BookSearchResultResponse searchWithISBN(String isbn) {
        return searchBookFromKakaoApi(API_URL_WITH_ISBN, isbn, "accuracy", 1);
    }

    private BookSearchResultResponse searchBookFromKakaoApi(String baseUrl, String searchKeyword, String sort, int page) {
        HttpHeaders headers = new HttpHeaders();
        headers.add(AUTHORIZATION_HEADER, KAKAO_AUTHORIZATION_HEADER_PREFIX + API_KEY);
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<HttpHeaders> httpEntity = new HttpEntity<>(headers);

        String requestUri = String.format(baseUrl, searchKeyword, sort, page);
        ResponseEntity<KakaoBookSearchResponse> response = restTemplate.exchange(requestUri,
                HttpMethod.GET, httpEntity, KakaoBookSearchResponse.class);

        List<Document> documents = response.getBody().getDocuments();

        if (documents.isEmpty()) {
            throw new BookSearchResultNotFoundException();
        }

        List<BookSearchResultDto> booSearchResultDtos = documents.stream()
                .map(BookDtoMapper.INSTANCE::kakaoSearchResponseToDto)
                .toList();

        if (isLastPage(response)) {
            return BookSearchResultResponse.of(booSearchResultDtos, "");
        }

        String nextRequestUrl = String.format(REQUEST_NEXT_URL, searchKeyword, sort, page + 1);
        return BookSearchResultResponse.of(booSearchResultDtos, nextRequestUrl);
    }

    private Boolean isLastPage(ResponseEntity<KakaoBookSearchResponse> response) {
        return response.getBody().getMeta().getIs_end();
    }
}
