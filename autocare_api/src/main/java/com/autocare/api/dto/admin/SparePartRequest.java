package com.autocare.api.dto.admin;

import java.math.BigDecimal;

public class SparePartRequest {
    private String partName;
    private String unit;
    private BigDecimal unitPrice;
    private Integer quantityInStock;
    private Integer minStockLevel;
    private String status;

    public String getPartName() { return partName; }
    public void setPartName(String partName) { this.partName = partName; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public Integer getQuantityInStock() { return quantityInStock; }
    public void setQuantityInStock(Integer quantityInStock) { this.quantityInStock = quantityInStock; }
    public Integer getMinStockLevel() { return minStockLevel; }
    public void setMinStockLevel(Integer minStockLevel) { this.minStockLevel = minStockLevel; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
