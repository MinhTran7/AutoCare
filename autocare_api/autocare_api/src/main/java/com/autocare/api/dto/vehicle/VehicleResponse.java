package com.autocare.api.dto.vehicle;

import com.autocare.api.entity.Vehicle;
import com.autocare.api.entity.VehicleStatus;

import java.time.LocalDateTime;

public class VehicleResponse {

    private Integer id;
    private String vehicleType;
    private String brand;
    private String model;
    private String licensePlate;
    private Integer manufacturingYear;
    private String color;
    private Integer mileage;
    private Boolean isDefault;
    private VehicleStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public VehicleResponse() {
    }

    public VehicleResponse(Vehicle vehicle) {
        this.id = vehicle.getId();
        this.vehicleType = vehicle.getVehicleType();
        this.brand = vehicle.getBrand();
        this.model = vehicle.getModel();
        this.licensePlate = vehicle.getLicensePlate();
        this.manufacturingYear = vehicle.getManufacturingYear();
        this.color = vehicle.getColor();
        this.mileage = vehicle.getMileage();
        this.isDefault = vehicle.getIsDefault();
        this.status = vehicle.getStatus();
        this.createdAt = vehicle.getCreatedAt();
        this.updatedAt = vehicle.getUpdatedAt();
    }

    public Integer getId() {
        return id;
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}