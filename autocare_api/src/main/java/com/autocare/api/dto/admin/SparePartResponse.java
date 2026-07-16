package com.autocare.api.dto.admin;

import com.autocare.api.entity.SparePart;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class SparePartResponse {
    private Integer id;
    private String partName;
    private String unit;
    private BigDecimal unitPrice;
    private Integer quantityInStock;
    private Integer minStockLevel;
    private String status;
    private boolean lowStock;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public SparePartResponse() {
    }

    public SparePartResponse(SparePart part) {
        this.id = part.getId();
        this.partName = part.getPartName();
        this.unit = part.getUnit();
        this.unitPrice = part.getUnitPrice();
        this.quantityInStock = part.getQuantityInStock();
        this.minStockLevel = part.getMinStockLevel();
        this.status = part.getStatus();
        this.lowStock = part.isLowStock();
        this.createdAt = part.getCreatedAt();
        this.updatedAt = part.getUpdatedAt();
    }

    public Integer getId() { return id; }
    public String getPartName() { return partName; }
    public String getUnit() { return unit; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public Integer getQuantityInStock() { return quantityInStock; }
    public Integer getMinStockLevel() { return minStockLevel; }
    public String getStatus() { return status; }
    public boolean isLowStock() { return lowStock; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
