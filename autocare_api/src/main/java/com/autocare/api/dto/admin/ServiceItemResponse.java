package com.autocare.api.dto.admin;

import com.autocare.api.entity.RepairService;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ServiceItemResponse {
    private Integer id;
    private String name;
    private String description;
    private BigDecimal price;
    private Boolean isHomeService;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public ServiceItemResponse() {
    }

    public ServiceItemResponse(RepairService item) {
        this.id = item.getId();
        this.name = item.getName();
        this.description = item.getDescription();
        this.price = item.getPrice();
        this.isHomeService = item.getIsHomeService();
        this.status = item.getStatus() != null ? item.getStatus().name() : null;
        this.createdAt = item.getCreatedAt();
        this.updatedAt = item.getUpdatedAt();
    }

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public BigDecimal getPrice() { return price; }
    public Boolean getIsHomeService() { return isHomeService; }
    public String getStatus() { return status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
