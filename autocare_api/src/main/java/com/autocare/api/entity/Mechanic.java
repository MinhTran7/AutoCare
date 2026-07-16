package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "mechanics")
@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Mechanic {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    // Mapping đến entity Garage (nếu bạn đã tạo)
    @Column(name = "garage_id")
    private Integer garageId;

    @Column(length = 100)
    private String specialty;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MechanicStatus status = MechanicStatus.AVAILABLE;

    @Column(precision = 2, scale = 1)
    private BigDecimal rating;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;
}

enum MechanicStatus {
    AVAILABLE, BUSY, OFF
}