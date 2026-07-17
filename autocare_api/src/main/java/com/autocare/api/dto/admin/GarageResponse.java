package com.autocare.api.dto.admin;

import com.autocare.api.entity.Garage;

import java.time.LocalDateTime;

public class GarageResponse {
    private Integer id;
    private String name;
    private String address;
    private String phone;
    private String status;
    private LocalDateTime createdAt;

    public GarageResponse() {
    }

    public GarageResponse(Garage garage) {
        this.id = garage.getId();
        this.name = garage.getName();
        this.address = garage.getAddress();
        this.phone = null;
        this.status = garage.getStatus() != null ? garage.getStatus().name() : null;
        this.createdAt = garage.getCreatedAt();
    }

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getAddress() { return address; }
    public String getPhone() { return phone; }
    public String getStatus() { return status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
