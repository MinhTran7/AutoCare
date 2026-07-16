package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "garages")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Garage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "text")
    private String address;

    private BigDecimal latitude;

    private BigDecimal longitude;

    @Enumerated(EnumType.STRING)
    private GarageStatus status;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum GarageStatus { ACTIVE, INACTIVE }
}