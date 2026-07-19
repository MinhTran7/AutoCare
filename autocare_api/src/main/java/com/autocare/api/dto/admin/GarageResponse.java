package com.autocare.api.dto.admin;

import com.autocare.api.entity.Garage;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class GarageResponse {
    private Integer id;
    private String name;
    private String address;
    private String phone;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public GarageResponse() {
    }

    public GarageResponse(Garage garage) {
        this.id = garage.getId();
        this.name = garage.getName();
        this.address = garage.getAddress();
        this.phone = null;
        this.latitude = garage.getLatitude();
        this.longitude = garage.getLongitude();
        this.status = garage.getStatus() != null ? garage.getStatus().name() : null;
        this.createdAt = garage.getCreatedAt();
        this.updatedAt = garage.getUpdatedAt();
    }

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getAddress() { return address; }
    public String getPhone() { return phone; }
    public BigDecimal getLatitude() { return latitude; }
    public BigDecimal getLongitude() { return longitude; }
    public String getStatus() { return status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
