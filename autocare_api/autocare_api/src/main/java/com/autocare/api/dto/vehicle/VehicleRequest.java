package com.autocare.api.dto.vehicle;

public class VehicleRequest {

    private String vehicleType;
    private String brand;
    private String model;
    private String licensePlate;
    private Integer manufacturingYear;
    private String color;
    private Integer mileage;
    private Boolean isDefault;

    public VehicleRequest() {
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
}