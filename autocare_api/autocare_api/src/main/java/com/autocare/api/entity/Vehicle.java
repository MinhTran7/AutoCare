package com.autocare.api.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "vehicles")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Chủ xe
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Loại xe: ô tô, xe máy
    @Column(name = "vehicle_type", nullable = false, length = 50)
    private String vehicleType;

    // Hãng xe: Honda, Yamaha, Toyota
    @Column(nullable = false, length = 100)
    private String brand;

    // Dòng xe: i10, SH, Vision
    @Column(nullable = false, length = 100)
    private String model;

    // Biển số xe
    @Column(name = "license_plate", nullable = false, length = 30)
    private String licensePlate;

    // Năm sản xuất
    @Column(name = "manufacturing_year")
    private Integer manufacturingYear;

    // Màu xe
    @Column(length = 50)
    private String color;

    // Số km đã đi
    @Column
    private Integer mileage;

    // Xe mặc định
    @Column(name = "is_default", nullable = false)
    private Boolean isDefault = false;

    // Trạng thái xe
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private VehicleStatus status = VehicleStatus.ACTIVE;

    // Thời gian khách hàng xóa mềm xe
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public Vehicle() {
    }

    @PrePersist
    public void onCreate() {
        LocalDateTime now = LocalDateTime.now();

        this.createdAt = now;
        this.updatedAt = now;

        if (this.mileage == null) {
            this.mileage = 0;
        }

        if (this.isDefault == null) {
            this.isDefault = false;
        }

        if (this.status == null) {
            this.status = VehicleStatus.ACTIVE;
        }
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public Integer getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public String getVehicleType() {
        return vehicleType;
    }

    public String getBrand() {
        return brand;
    }

    public String getModel() {
        return model;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public Integer getManufacturingYear() {
        return manufacturingYear;
    }

    public String getColor() {
        return color;
    }

    public Integer getMileage() {
        return mileage;
    }

    public Boolean getIsDefault() {
        return isDefault;
    }

    public VehicleStatus getStatus() {
        return status;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setVehicleType(String vehicleType) {
        this.vehicleType = vehicleType;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }

    public void setManufacturingYear(Integer manufacturingYear) {
        this.manufacturingYear = manufacturingYear;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public void setMileage(Integer mileage) {
        this.mileage = mileage;
    }

    public void setIsDefault(Boolean isDefault) {
        this.isDefault = isDefault;
    }

    public void setStatus(VehicleStatus status) {
        this.status = status;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}