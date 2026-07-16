package com.autocare.api.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "spare_parts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SparePart {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "part_name", nullable = false, length = 150)
    private String partName;

    @Column(nullable = false, length = 30)
    private String unit;

    @Column(name = "unit_price", precision = 15, scale = 2)
    private BigDecimal unitPrice;

    @Builder.Default
    @Column(name = "quantity_in_stock", nullable = false)
    private Integer quantityInStock = 0;

    @Builder.Default
    @Column(name = "min_stock_level", nullable = false)
    private Integer minStockLevel = 0;

    @Builder.Default
    @Column(nullable = false, length = 20)
    private String status = "ACTIVE";

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    public void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (quantityInStock == null) {
            quantityInStock = 0;
        }
        if (minStockLevel == null) {
            minStockLevel = 0;
        }
        if (status == null || status.isBlank()) {
            status = "ACTIVE";
        }
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    @Transient
    public boolean isLowStock() {
        return quantityInStock != null
                && minStockLevel != null
                && quantityInStock <= minStockLevel;
    }
}
