package com.autocare.api.dto.admin;

public class UpdateMechanicStatusRequest {

    private String lockedReason;

    public UpdateMechanicStatusRequest() {
    }

    public String getLockedReason() {
        return lockedReason;
    }

    public void setLockedReason(String lockedReason) {
        this.lockedReason = lockedReason;
    }
}