package com.autocare.api.dto.admin;

import com.autocare.api.entity.User;

import java.time.LocalDateTime;

public class CustomerAccountResponse {
    private Integer id;
    private String fullName;
    private String email;
    private String phone;
    private String address;
    private String status;
    private String lockedReason;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public CustomerAccountResponse() {
    }

    public CustomerAccountResponse(User user) {
        this.id = user.getId();
        this.fullName = user.getFullName();
        this.email = user.getEmail();
        this.phone = user.getPhone();
        this.address = user.getAddress();
        this.status = user.getStatus();
        this.lockedReason = user.getLockedReason();
        this.createdAt = user.getCreatedAt();
        this.updatedAt = user.getUpdatedAt();
    }

    public Integer getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public String getAddress() { return address; }
    public String getStatus() { return status; }
    public String getLockedReason() { return lockedReason; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
