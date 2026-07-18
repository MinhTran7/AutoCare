package com.autocare.api.controller;

import com.autocare.api.entity.Booking;
import com.autocare.api.entity.Invoice;
import com.autocare.api.service.MechanicService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/mechanics")
@RequiredArgsConstructor
public class MechanicController {

    private final MechanicService mechanicService;

    /**
     * 1. API: Thợ máy nhận đơn sửa chữa
     * Endpoint: PUT /api/mechanics/bookings/{bookingId}/accept
     */
    @PutMapping("/bookings/{bookingId}/accept")
    public ResponseEntity<?> acceptBooking(
            @PathVariable Integer bookingId,
            @RequestAttribute("userId") Integer mechanicId) {
        try {
            // Gọi hàm acceptBooking từ Service đã viết ở trên
            Booking booking = mechanicService.acceptBooking(bookingId, mechanicId);
            return ResponseEntity.ok(booking);
        } catch (RuntimeException e) {
            // Bắt exception từ Service (ví dụ: lỗi nhận đơn khác ngày)
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * 2. API: Hoàn thành đơn, chốt phụ tùng và tính tổng tiền
     * Endpoint: PUT /api/mechanics/bookings/{bookingId}/complete
     */
    @PutMapping("/bookings/{bookingId}/complete")
    public ResponseEntity<?> completeBooking(@PathVariable Integer bookingId) {
        try {
            // Gọi hàm completeBookingAndCalculateTotal từ Service
            Invoice invoice = mechanicService.completeBookingAndCalculateTotal(bookingId);
            return ResponseEntity.ok(invoice);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * 3. API: Chấm công (Check-in) đầu ca
     * Endpoint: POST /api/mechanics/check-in
     */
    @PostMapping("/check-in")
    public ResponseEntity<?> checkIn(@RequestAttribute("userId") Integer mechanicId) {
        try {
            // Gọi hàm checkIn từ Service
            mechanicService.checkIn(mechanicId);
            return ResponseEntity.ok("Check-in thành công cho ngày hôm nay!");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}