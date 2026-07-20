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

    @Column(name = "part_name", nullable = false, length = 200)
    private String partName;

    @Column(nullable = false, length = 50)
    private String unit;

    /** Giá nhập — cột sẵn có trên DB nhóm */
    @Column(name = "cost_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal costPrice;

    /** Giá bán — cột sẵn có trên DB nhóm (Admin hiển thị làm đơn giá) */
    @Column(name = "selling_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal sellingPrice;

    @Builder.Default
    @Column(name = "quantity_in_stock", nullable = false)
    private Integer quantityInStock = 0;

    @Builder.Default
    @Column(name = "min_stock_level", nullable = false)
    private Integer minStockLevel = 0;

    /** Cột status đã có trên Aiven (Hibernate từng tạo) — map lại để INSERT không thiếu NOT NULL */
    @Builder.Default
    @Column(nullable = false, length = 20)
    private String status = "ACTIVE";

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;

    @Transient
    public boolean isLowStock() {
        return quantityInStock != null
                && minStockLevel != null
                && quantityInStock <= minStockLevel;
    }
}
