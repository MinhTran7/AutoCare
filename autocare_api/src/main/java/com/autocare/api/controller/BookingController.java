package com.autocare.api.controller;


import com.autocare.api.dto.request.BookingRequestDTO;
import com.autocare.api.dto.response.BookingResponseDTO;
import com.autocare.api.service.BookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Man hinh 5A/5B, 6, 7: dia chi -> xac nhan -> dat lich thanh cong. */
@RestController
@RequestMapping("/api/bookings")
@CrossOrigin("*")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public BookingResponseDTO createBooking(@Valid @RequestBody BookingRequestDTO request) {
        return bookingService.createBooking(request);
    }

    @GetMapping("/{id}")
    public BookingResponseDTO getBooking(@PathVariable Integer id) {
        return bookingService.getBooking(id);
    }

    @GetMapping("/user/{userId}")
    public List<BookingResponseDTO> getBookingsOfUser(@PathVariable Integer userId) {
        return bookingService.getBookingsOfUser(userId);
    }

    // Thêm endpoint này vào BookingController.java
    @GetMapping("/my-bookings")
    public List<BookingResponseDTO> getMyBookings() {
        // Gọi hàm lấy danh sách booking của chính người dùng đang đăng nhập dựa vào Token
        return bookingService.getMyBookings();
    }
}

