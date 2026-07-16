package com.autocare.api.dto.response;

import com.autocare.api.entity.Notification;

import java.time.LocalDateTime;

public class NotificationResponse {

    private Integer id;
    private Integer userId;
    private Integer bookingId;
    private String type;
    private String title;
    private String body;
    private Boolean isRead;
    private LocalDateTime createdAt;

    public NotificationResponse() {
    }

    public NotificationResponse(Notification notification) {
        this.id        = notification.getId();
        this.userId    = notification.getUserId();
        this.bookingId = notification.getBookingId();
        this.type      = notification.getType();
        this.title     = notification.getTitle();
        this.body      = notification.getBody();
        this.isRead    = notification.getIsRead();
        this.createdAt = notification.getCreatedAt();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getBookingId() { return bookingId; }
    public void setBookingId(Integer bookingId) { this.bookingId = bookingId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public Boolean getIsRead() { return isRead; }
    public void setIsRead(Boolean isRead) { this.isRead = isRead; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}