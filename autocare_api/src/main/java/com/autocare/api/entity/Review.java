package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "reviews",
        indexes = {
                @Index(name = "idx_review_garage", columnList = "garage_id"),
                @Index(name = "idx_review_user",   columnList = "user_id"),
                @Index(name = "idx_review_rating", columnList = "rating")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // ── Quan hệ với Booking ──────────────────────────────────────────────────
    // Mỗi booking chỉ được review đúng 1 lần (unique)
    // TODO: Bật khi TV2 đã có Booking entity
    // @OneToOne(fetch = FetchType.LAZY)
    // @JoinColumn(name = "booking_id", nullable = false, unique = true)
    // private Booking booking;

    @Column(name = "booking_id", nullable = false, unique = true)
    private Integer bookingId;

    // ── Quan hệ với User ─────────────────────────────────────────────────────
    // TODO: Bật khi muốn load thông tin người viết review
    // @ManyToOne(fetch = FetchType.LAZY)
    // @JoinColumn(name = "user_id", nullable = false)
    // private User user;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    // ── Quan hệ với Garage ───────────────────────────────────────────────────
    // TODO: Bật khi TV2 đã có Garage entity
    // @ManyToOne(fetch = FetchType.LAZY)
    // @JoinColumn(name = "garage_id", nullable = false)
    // private Garage garage;

    @Column(name = "garage_id", nullable = false)
    private Integer garageId;

    // ── Nội dung đánh giá ────────────────────────────────────────────────────
    // 1 đến 5 sao — validate ở Service trước khi lưu
    @Column(nullable = false)
    private Integer rating;

    @Column(columnDefinition = "TEXT")
    private String comment;

    // Danh sách URL ảnh, lưu dạng JSON string: ["url1","url2"]
    @Column(columnDefinition = "JSON")
    private String images;

    // Admin có thể ẩn review vi phạm mà không xoá
    @Builder.Default
    @Column(name = "is_visible", nullable = false)
    private Boolean isVisible = true;

    // ── Timestamp ────────────────────────────────────────────────────────────
    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (isVisible == null) isVisible = true;
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}