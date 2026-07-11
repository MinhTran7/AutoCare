package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "booking_slots", uniqueConstraints = {
        @UniqueConstraint(name = "uk_garage_slot", columnNames = {"garage_id", "booking_date", "start_time", "end_time"})
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "garage_id", nullable = false)
    private Garage garage;

    @Column(name = "booking_date", nullable = false)
    private LocalDate bookingDate;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalTime endTime;

    @Enumerated(EnumType.STRING)
    private SlotStatus status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum SlotStatus { AVAILABLE, BOOKED, CANCELLED }
}
