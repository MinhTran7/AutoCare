package com.autocare.api.dto.response;

import com.autocare.api.entity.BookingStatusLog;

import java.time.LocalDateTime;

public class BookingStatusLogResponse {

    private Integer id;
    private Integer bookingId;
    private String oldStatus;
    private String newStatus;
    private Integer changedBy;
    private String note;
    private LocalDateTime changedAt;

    public BookingStatusLogResponse() {
    }

    public BookingStatusLogResponse(BookingStatusLog log) {
        this.id        = log.getId();
        this.bookingId = log.getBookingId();
        this.oldStatus = log.getOldStatus();
        this.newStatus = log.getNewStatus();
        // getChangedBy() giờ trả về User object → lấy getId()
        this.changedBy = log.getChangedBy() != null ? log.getChangedBy().getId() : null;
        this.note      = log.getNote();
        this.changedAt = log.getChangedAt();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getBookingId() { return bookingId; }
    public void setBookingId(Integer bookingId) { this.bookingId = bookingId; }

    public String getOldStatus() { return oldStatus; }
    public void setOldStatus(String oldStatus) { this.oldStatus = oldStatus; }

    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }

    public Integer getChangedBy() { return changedBy; }
    public void setChangedBy(Integer changedBy) { this.changedBy = changedBy; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public LocalDateTime getChangedAt() { return changedAt; }
    public void setChangedAt(LocalDateTime changedAt) { this.changedAt = changedAt; }
}