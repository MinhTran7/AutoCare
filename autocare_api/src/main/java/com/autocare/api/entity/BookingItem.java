package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "booking_items")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_id", nullable = false)
    private RepairService service;

    @Column(nullable = false)
    private BigDecimal price;
}