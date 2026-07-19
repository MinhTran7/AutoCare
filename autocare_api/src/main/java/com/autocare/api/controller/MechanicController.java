package com.autocare.api.controller;

import com.autocare.api.entity.Booking;
import com.autocare.api.entity.Invoice;
import com.autocare.api.entity.Mechanic;
import com.autocare.api.repository.MechanicRepository;
import com.autocare.api.repository.UserRepository;
import com.autocare.api.service.MechanicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;

import java.util.List;

@RestController
@RequestMapping("/api/mechanics")
@RequiredArgsConstructor
public class MechanicController {

    private final MechanicService mechanicService;

    @GetMapping("/bookings/waiting")
    public ResponseEntity<?> getWaitingBookings(
            @RequestAttribute("userId") Integer userId){

        try{

            return ResponseEntity.ok(
                    mechanicService.getWaitingBookings(userId));

        }catch(RuntimeException e){

            return ResponseEntity.badRequest()
                    .body(e.getMessage());

        }

    }

    @GetMapping("/bookings/my")
    public ResponseEntity<?> getMyBookings(
            @RequestAttribute("userId") Integer userId){

        try{

            return ResponseEntity.ok(
                    mechanicService.getMyBookings(userId));

        }catch(RuntimeException e){

            return ResponseEntity.badRequest()
                    .body(e.getMessage());

        }

    }

    /**
     * 1. API: Thợ máy nhận đơn sửa chữa
     * Endpoint: PUT /api/mechanics/bookings/{bookingId}/accept
     */
    @PutMapping("/bookings/{bookingId}/accept")
    public ResponseEntity<?> acceptBooking(
            @PathVariable Integer bookingId,
            @RequestAttribute("userId") Integer userId) {
        try {
            // Gọi hàm acceptBooking từ Service đã viết ở trên
            Booking booking = mechanicService.acceptBooking(bookingId, userId);
            return ResponseEntity.ok(booking);
        } catch (RuntimeException e) {
            // Bắt exception từ Service (ví dụ: lỗi nhận đơn khác ngày)
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/bookings/confirmed")
    public ResponseEntity<?> getConfirmedBookings(
            @RequestAttribute("userId") Integer userId) {

        try {

            return ResponseEntity.ok(
                    mechanicService.getConfirmedBookings(userId));

        } catch (RuntimeException e) {

            return ResponseEntity.badRequest().body(e.getMessage());

        }
    }

    @PutMapping("/bookings/{bookingId}/start")
    public ResponseEntity<?> startRepair(
            @PathVariable Integer bookingId,
            @RequestAttribute("userId") Integer userId){

        try{

            Booking booking =
                    mechanicService.startRepair(
                            bookingId,
                            userId);

            return ResponseEntity.ok(booking);

        }catch(RuntimeException e){

            return ResponseEntity.badRequest().body(e.getMessage());

        }
    }

    @GetMapping("/bookings/repairing")
    public ResponseEntity<?> getRepairingBookings(
            @RequestAttribute("userId") Integer userId) {

        try {

            return ResponseEntity.ok(
                    mechanicService.getRepairingBookings(userId));

        } catch (RuntimeException e) {

            return ResponseEntity.badRequest().body(e.getMessage());

        }
    }

    @PutMapping("/bookings/{bookingId}/reject")
    public ResponseEntity<?> rejectBooking(
            @PathVariable Integer bookingId,
            @RequestAttribute("userId") Integer userId) {

        try {

            Booking booking = mechanicService.rejectBooking(
                    bookingId,
                    userId);

            return ResponseEntity.ok(booking);

        } catch (RuntimeException e) {

            return ResponseEntity.badRequest().body(e.getMessage());

        }
    }

    /**
     * 2. API: Hoàn thành đơn, chốt phụ tùng và tính tổng tiền
     * Endpoint: PUT /api/mechanics/bookings/{bookingId}/complete
     */
    @PutMapping("/bookings/{bookingId}/complete")
    public ResponseEntity<?> completeBooking(
            @PathVariable Integer bookingId,
            @RequestAttribute("userId") Integer userId) {

        try {

            Invoice invoice = mechanicService.completeBookingAndCalculateTotal(
                    bookingId,
                    userId);

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
    public ResponseEntity<?> checkIn(@RequestAttribute("userId") Integer userId) {
        try {
            // Gọi hàm checkIn từ Service
            mechanicService.checkIn(userId);
            return ResponseEntity.ok("Check-in thành công cho ngày hôm nay!");
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/check-out")
    public ResponseEntity<?> checkOut(
            @RequestAttribute("userId") Integer userId) {

        try {

            mechanicService.checkOut(userId);

            return ResponseEntity.ok("Check-out thành công!");

        } catch (RuntimeException e) {

            return ResponseEntity.badRequest().body(e.getMessage());

        }
    }

    @GetMapping("/attendance")
    public ResponseEntity<?> getAttendanceHistory(
            @RequestAttribute("userId") Integer userId){

        try{

            return ResponseEntity.ok(
                    mechanicService.getAttendanceHistory(userId));

        }catch(RuntimeException e){

            return ResponseEntity.badRequest().body(e.getMessage());

        }
    }

}