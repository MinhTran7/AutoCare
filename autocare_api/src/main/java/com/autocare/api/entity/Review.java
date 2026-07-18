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

    // ── Quan hệ với Booking (TV2 đã có Booking entity) ───────────────────────
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false, unique = true)
    private Booking booking;

    public Integer getBookingId() {
        return booking != null ? booking.getId() : null;
    }

    // ── Quan hệ với User ─────────────────────────────────────────────────────
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    public Integer getUserId() {
        return user != null ? user.getId() : null;
    }

    // ── Quan hệ với Garage (TV2 đã có Garage entity) ─────────────────────────
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "garage_id", nullable = false)
    private Garage garage;

    public Integer getGarageId() {
        return garage != null ? garage.getId() : null;
    }

    @Column(nullable = false)
    private Integer rating;

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Column(columnDefinition = "JSON")
    private String images;

    @Builder.Default
    @Column(name = "is_visible", nullable = false)
    private Boolean isVisible = true;

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