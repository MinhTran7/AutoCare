package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;

/** Anh xa toi bang `garage_services` (garage nao co dich vu nao). */
@Entity
@Table(name = "garage_services", uniqueConstraints = {
        @UniqueConstraint(name = "uk_garage_service", columnNames = {"garage_id", "service_id"})
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GarageServiceLink {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "garage_id", nullable = false)
    private Garage garage;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_id", nullable = false)
    private RepairService service;
}