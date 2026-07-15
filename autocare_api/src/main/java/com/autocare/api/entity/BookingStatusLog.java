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

    // ── Quan hệ với Booking ──────────────────────────────────────────────────
    // TODO: Bật khi TV2 đã có Booking entity
    // @ManyToOne(fetch = FetchType.LAZY)
    // @JoinColumn(name = "booking_id", nullable = false)
    // private Booking booking;

    @Column(name = "booking_id", nullable = false)
    private Integer bookingId;

    // ── Quan hệ với User (người thay đổi trạng thái) ────────────────────────
    // TODO: Bật khi muốn load thông tin người thay đổi
    // @ManyToOne(fetch = FetchType.LAZY)
    // @JoinColumn(name = "changed_by")
    // private User changedBy;

    @Column(name = "changed_by")
    private Integer changedBy;

    // ── Trạng thái ──────────────────────────────────────────────────────────
    // null nếu là bước đầu tiên (PENDING)
    @Column(name = "old_status", length = 30)
    private String oldStatus;

    // PENDING | CONFIRMED | IN_PROGRESS | COMPLETED | CANCELLED
    @Column(name = "new_status", nullable = false, length = 30)
    private String newStatus;

    // Ghi chú cho bước này, vd: "Thợ đã đến nơi, bắt đầu kiểm tra"
    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "changed_at", nullable = false)
    private LocalDateTime changedAt;

    @PrePersist
    public void onCreate() {
        if (changedAt == null) changedAt = LocalDateTime.now();
    }
}