package com.autocare.api.dto.admin;

public class CreateMechanicRequest {

    private String fullName;
    private String email;
    private String phone;
    private String password;
    private String address;
    private String avatarUrl;
    private Integer garageId;

    public CreateMechanicRequest() {
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getPassword() {
        return password;
    }

    public String getAddress() {
        return address;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public Integer getGarageId() {
        return garageId;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public void setGarageId(Integer garageId) {
        this.garageId = garageId;
    }
}