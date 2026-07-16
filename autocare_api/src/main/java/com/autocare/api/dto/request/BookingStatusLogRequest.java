package com.autocare.api.dto.request;

public class BookingStatusLogRequest {

    private String newStatus;   // CONFIRMED | IN_PROGRESS | COMPLETED | CANCELLED
    private String note;
    private Integer customerUserId; // nullable — TV4 truyền vào để tự gửi thông báo

    public BookingStatusLogRequest() {}

    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public Integer getCustomerUserId() { return customerUserId; }
    public void setCustomerUserId(Integer customerUserId) { this.customerUserId = customerUserId; }
}