package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "notifications",
        indexes = {
                @Index(name = "idx_noti_user_read",  columnList = "user_id, is_read"),
                @Index(name = "idx_noti_booking",    columnList = "booking_id"),
                @Index(name = "idx_noti_created_at", columnList = "created_at")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // ── Quan hệ với User (người nhận) ────────────────────────────────────────
    // TODO: Bật khi muốn load thông tin người nhận
    // @ManyToOne(fetch = FetchType.LAZY)
    // @JoinColumn(name = "user_id", nullable = false)
    // private User user;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    // ── Quan hệ với Booking ──────────────────────────────────────────────────
    // Nullable — thông báo promo không cần booking
    // TODO: Bật khi TV2 đã có Booking entity
    // @ManyToOne(fetch = FetchType.LAZY)
    // @JoinColumn(name = "booking_id")
    // private Booking booking;

    @Column(name = "booking_id")
    private Integer bookingId;

    // ── Nội dung ─────────────────────────────────────────────────────────────
    // booking_confirmed | status_update | invoice_ready | review_reminder | promo
    @Column(nullable = false, length = 50)
    private String type;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    // false = chưa đọc → hiện badge đỏ trên app
    @Builder.Default
    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (isRead    == null) isRead    = false;
    }
}