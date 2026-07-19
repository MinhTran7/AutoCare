package com.autocare.api.service;

import com.autocare.api.entity.Booking;
import com.autocare.api.entity.Garage;
import com.autocare.api.entity.Review;
import com.autocare.api.entity.User;
import com.autocare.api.repository.BookingRepository;
import com.autocare.api.repository.ReviewRepository;
import com.autocare.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;
    private final BookingStatusLogService bookingStatusLogService;

    public ReviewService(
            ReviewRepository reviewRepository,
            UserRepository userRepository,
            BookingRepository bookingRepository,
            BookingStatusLogService bookingStatusLogService
    ) {
        this.reviewRepository = reviewRepository;
        this.userRepository = userRepository;
        this.bookingRepository = bookingRepository;
        this.bookingStatusLogService = bookingStatusLogService;
    }

    @Transactional(readOnly = true)
    public List<Review> getGarageReviews(Integer garageId) {
        return reviewRepository
                .findByGarage_IdAndIsVisibleTrueOrderByCreatedAtDesc(garageId);
    }

    public List<Review> getMyReviews() {
        User currentUser = getCurrentUser();
        return reviewRepository
                .findByUser_IdOrderByCreatedAtDesc(currentUser.getId());
    }

    public Review getByBookingId(Integer bookingId) {
        return reviewRepository
                .findByBooking_Id(bookingId)
                .orElseThrow(() -> new RuntimeException("Chưa có đánh giá cho booking này"));
    }

    @Transactional
    public Review createReview(Integer bookingId, Integer garageId,
                               Integer rating, String comment, String images) {
        User currentUser = getCurrentUser();

        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy booking #" + bookingId));

        String currentStatus = bookingStatusLogService.getCurrentStatus(bookingId);
        if (!"COMPLETED".equals(currentStatus)) {
            throw new RuntimeException("Chỉ có thể đánh giá sau khi dịch vụ hoàn thành");
        }

        if (reviewRepository.existsByBooking_Id(bookingId)) {
            throw new RuntimeException("Bạn đã đánh giá booking này rồi");
        }

        validateRating(rating);

        Garage garage = booking.getGarage();

        Review review = Review.builder()
                .booking(booking)
                .user(currentUser)
                .garage(garage)
                .rating(rating)
                .comment(normalizeNullable(comment))
                .images(images)
                .isVisible(true)
                .build();

        return reviewRepository.save(review);
    }

    @Transactional
    public Review updateReview(Integer bookingId, Integer rating,
                               String comment, String images) {
        User currentUser = getCurrentUser();

        Review review = reviewRepository
                .findByBooking_Id(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đánh giá"));

        if (!review.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("Bạn không có quyền sửa đánh giá này");
        }

        validateRating(rating);
        review.setRating(rating);
        review.setComment(normalizeNullable(comment));
        review.setImages(images);

        return reviewRepository.save(review);
    }

    public void deleteReview(Integer bookingId) {
        User currentUser = getCurrentUser();

        Review review = reviewRepository
                .findByBooking_Id(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đánh giá"));

        if (!review.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("Bạn không có quyền xoá đánh giá này");
        }

        reviewRepository.delete(review);
    }

    public Review toggleVisibility(Integer reviewId) {
        Review review = reviewRepository
                .findById(reviewId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đánh giá"));
        review.setIsVisible(!review.getIsVisible());
        return reviewRepository.save(review);
    }

    public List<Review> getGarageReviewsByRating(Integer garageId, Integer rating) {
        validateRating(rating);
        return reviewRepository
                .findByGarage_IdAndRatingAndIsVisibleTrue(garageId, rating);
    }

    private void validateRating(Integer rating) {
        if (rating == null || rating < 1 || rating > 5) {
            throw new RuntimeException("Số sao phải từ 1 đến 5");
        }
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new RuntimeException("Bạn chưa đăng nhập");
        }
        return userRepository
                .findByEmailOrPhone(auth.getName(), auth.getName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private String normalizeNullable(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        return value.trim();
    }
}