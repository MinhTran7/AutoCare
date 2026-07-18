package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "booking_status_logs",
        indexes = {
                @Index(name = "idx_status_log_booking",    columnList = "booking_id"),
                @Index(name = "idx_status_log_changed_at", columnList = "changed_at")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingStatusLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // ── Quan hệ với Booking (TV2 đã có Booking entity) ───────────────────────
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    public Integer getBookingId() {
        return booking != null ? booking.getId() : null;
    }

    // ── Quan hệ với User ─────────────────────────────────────────────────────
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by")
    private User changedBy;

    public Integer getChangedById() {
        return changedBy != null ? changedBy.getId() : null;
    }

    @Column(name = "old_status", length = 30)
    private String oldStatus;

    @Column(name = "new_status", nullable = false, length = 30)
    private String newStatus;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "changed_at", nullable = false)
    private LocalDateTime changedAt;

    @PrePersist
    public void onCreate() {
        if (changedAt == null) changedAt = LocalDateTime.now();
    }
}