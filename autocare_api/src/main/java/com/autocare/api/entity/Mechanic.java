package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "mechanics")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Mechanic {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Integer userId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "garage_id")
    private Garage garage;

    private String specialty;

    @Enumerated(EnumType.STRING)
    private MechanicStatus status;

    private BigDecimal rating;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum MechanicStatus { AVAILABLE, BUSY, OFF }
}
