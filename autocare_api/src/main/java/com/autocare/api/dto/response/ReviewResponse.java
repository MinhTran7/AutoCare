package com.autocare.api.dto.response;

import com.autocare.api.entity.Review;
import com.autocare.api.entity.Booking;
import java.time.LocalDateTime;

public class ReviewResponse {

    private Integer id;
    private Integer bookingId;
    private Integer userId;
    private Integer garageId;
    private Integer serviceId;      // MỚI
    private String serviceName;     // MỚI
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

        // MỚI: lấy serviceId/serviceName qua booking -> service
        if (review.getBooking() != null &&
                review.getBooking().getBookingItems() != null &&
                !review.getBooking().getBookingItems().isEmpty()) {

            // Lấy dịch vụ đầu tiên trong danh sách (giả định 1 booking = 1 service)
            var firstItem = review.getBooking().getBookingItems().get(0);
            this.serviceId = firstItem.getService().getId();
            this.serviceName = firstItem.getService().getName();
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

    public Integer getServiceId() { return serviceId; }
    public void setServiceId(Integer serviceId) { this.serviceId = serviceId; }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

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