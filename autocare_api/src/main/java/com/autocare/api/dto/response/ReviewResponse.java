package com.autocare.api.dto.response;

import com.autocare.api.entity.Review;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public class ReviewResponse {

    private Integer id;
    private Integer bookingId;
    private Integer userId;
    private Integer garageId;
    private List<String> serviceNames;   // MỚI: danh sách tên dịch vụ trong booking này
    private Integer rating;
    private String comment;
    private String images;
    private Boolean isVisible;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public ReviewResponse() {
    }

    public ReviewResponse(Review review) {
        this.id        = review.getId();
        this.bookingId = review.getBookingId();
        this.userId    = review.getUserId();
        this.garageId  = review.getGarageId();
        this.rating    = review.getRating();
        this.comment   = review.getComment();
        this.images    = review.getImages();
        this.isVisible = review.getIsVisible();
        this.createdAt = review.getCreatedAt();
        this.updatedAt = review.getUpdatedAt();

        // MỚI: lấy danh sách tên dịch vụ qua booking -> bookingItems -> service
        if (review.getBooking() != null && review.getBooking().getBookingItems() != null) {
            this.serviceNames = review.getBooking().getBookingItems().stream()
                    .filter(bi -> bi.getService() != null)
                    .map(bi -> bi.getService().getName())
                    .collect(Collectors.toList());
        } else {
            this.serviceNames = List.of();
        }
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getBookingId() { return bookingId; }
    public void setBookingId(Integer bookingId) { this.bookingId = bookingId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getGarageId() { return garageId; }
    public void setGarageId(Integer garageId) { this.garageId = garageId; }

    public List<String> getServiceNames() { return serviceNames; }
    public void setServiceNames(List<String> serviceNames) { this.serviceNames = serviceNames; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public String getImages() { return images; }
    public void setImages(String images) { this.images = images; }

    public Boolean getIsVisible() { return isVisible; }
    public void setIsVisible(Boolean isVisible) { this.isVisible = isVisible; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}