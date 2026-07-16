package com.autocare.api.controller;

import com.autocare.api.dto.request.ReviewRequest;
import com.autocare.api.dto.response.ReviewResponse;
import com.autocare.api.entity.Review;
import com.autocare.api.service.ReviewService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reviews")
@CrossOrigin("*")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    // GET /api/reviews/garage/{garageId}
    // Lấy tất cả review của 1 garage (public)
    @GetMapping("/garage/{garageId}")
    public ResponseEntity<List<ReviewResponse>> getGarageReviews(
            @PathVariable Integer garageId
    ) {
        List<ReviewResponse> reviews = reviewService
                .getGarageReviews(garageId)
                .stream()
                .map(ReviewResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(reviews);
    }

    // GET /api/reviews/garage/{garageId}?rating=5
    // Lấy review theo số sao
    @GetMapping("/garage/{garageId}/filter")
    public ResponseEntity<List<ReviewResponse>> getGarageReviewsByRating(
            @PathVariable Integer garageId,
            @RequestParam Integer rating
    ) {
        List<ReviewResponse> reviews = reviewService
                .getGarageReviewsByRating(garageId, rating)
                .stream()
                .map(ReviewResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(reviews);
    }

    // GET /api/reviews/me
    // Lấy tất cả review của user hiện tại
    @GetMapping("/me")
    public ResponseEntity<List<ReviewResponse>> getMyReviews() {
        List<ReviewResponse> reviews = reviewService
                .getMyReviews()
                .stream()
                .map(ReviewResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(reviews);
    }

    // GET /api/reviews/booking/{bookingId}
    // Lấy review theo bookingId
    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<ReviewResponse> getByBookingId(
            @PathVariable Integer bookingId
    ) {
        Review review = reviewService.getByBookingId(bookingId);
        return ResponseEntity.ok(new ReviewResponse(review));
    }

    // POST /api/reviews/booking/{bookingId}
    // Tạo review sau khi dịch vụ hoàn thành
    @PostMapping("/booking/{bookingId}")
    public ResponseEntity<ReviewResponse> createReview(
            @PathVariable Integer bookingId,
            @RequestBody ReviewRequest request
    ) {
        Review review = reviewService.createReview(
                bookingId,
                request.getGarageId(),
                request.getRating(),
                request.getComment(),
                request.getImages()
        );
        return ResponseEntity.ok(new ReviewResponse(review));
    }

    // PUT /api/reviews/booking/{bookingId}
    // Sửa review
    @PutMapping("/booking/{bookingId}")
    public ResponseEntity<ReviewResponse> updateReview(
            @PathVariable Integer bookingId,
            @RequestBody ReviewRequest request
    ) {
        Review review = reviewService.updateReview(
                bookingId,
                request.getRating(),
                request.getComment(),
                request.getImages()
        );
        return ResponseEntity.ok(new ReviewResponse(review));
    }

    // DELETE /api/reviews/booking/{bookingId}
    // Xoá review
    @DeleteMapping("/booking/{bookingId}")
    public ResponseEntity<Map<String, String>> deleteReview(
            @PathVariable Integer bookingId
    ) {
        reviewService.deleteReview(bookingId);
        return ResponseEntity.ok(Map.of("message", "Xoá đánh giá thành công"));
    }

    // PATCH /api/reviews/{id}/visibility
    // Ẩn/hiện review (Admin)
    @PatchMapping("/{id}/visibility")
    public ResponseEntity<ReviewResponse> toggleVisibility(
            @PathVariable Integer id
    ) {
        Review review = reviewService.toggleVisibility(id);
        return ResponseEntity.ok(new ReviewResponse(review));
    }
}