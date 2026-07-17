package com.autocare.api.dto.admin;

import java.math.BigDecimal;

public class ServiceItemRequest {
    private String name;
    private String description;
    private BigDecimal price;
    private Boolean isHomeService;
    private String status;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Boolean getIsHomeService() { return isHomeService; }
    public void setIsHomeService(Boolean isHomeService) { this.isHomeService = isHomeService; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
