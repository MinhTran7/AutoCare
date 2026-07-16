package com.autocare.api.service;

import com.autocare.api.dto.response.BookingResponse; // Giả sử bạn đã có DTO này
import java.util.List;

public interface MechanicService {
    void updateStatus(Integer userId, String status);
    List<BookingResponse> getAssignedBookings(Integer userId);
    void updateBookingStatus(Integer mechanicUserId, Integer bookingId, String newStatus);
}