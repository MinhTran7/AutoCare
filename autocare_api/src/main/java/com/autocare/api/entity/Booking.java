package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "customer_id")
    private Integer customerId;

    @Column(name = "vehicle_id")
    private Integer vehicleId;

    @Column(name = "garage_id")
    private Integer garageId;

    @Column(name = "service_id")
    private Integer serviceId;

    @Column(name = "mechanic_id")
    private Integer mechanicId;

    @Builder.Default
    @Column(name = "booking_type", nullable = false, length = 20)
    private String bookingType = "GARAGE";

    @Builder.Default
    @Column(nullable = false, length = 30)
    private String status = "PENDING";

    @Column(name = "scheduled_at")
    private LocalDateTime scheduledAt;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    public void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (bookingType == null || bookingType.isBlank()) {
            bookingType = "GARAGE";
        }
        if (status == null || status.isBlank()) {
            status = "PENDING";
        }
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
