package com.autocare.api.controller;

import com.autocare.api.dto.request.BookingStatusLogRequest;
import com.autocare.api.dto.response.BookingStatusLogResponse;
import com.autocare.api.entity.BookingStatusLog;
import com.autocare.api.service.BookingStatusLogService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/bookings")
@CrossOrigin("*")
public class BookingStatusLogController {

    private final BookingStatusLogService bookingStatusLogService;

    public BookingStatusLogController(BookingStatusLogService bookingStatusLogService) {
        this.bookingStatusLogService = bookingStatusLogService;
    }

    // GET /api/bookings/{bookingId}/timeline
    @GetMapping("/{bookingId}/timeline")
    public ResponseEntity<List<BookingStatusLogResponse>> getTimeline(
            @PathVariable Integer bookingId
    ) {
        List<BookingStatusLogResponse> timeline = bookingStatusLogService
                .getTimeline(bookingId)
                .stream()
                .map(BookingStatusLogResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(timeline);
    }

    // GET /api/bookings/{bookingId}/status
    @GetMapping("/{bookingId}/status")
    public ResponseEntity<Map<String, String>> getCurrentStatus(
            @PathVariable Integer bookingId
    ) {
        String status = bookingStatusLogService.getCurrentStatus(bookingId);
        return ResponseEntity.ok(Map.of("status", status));
    }

    // POST /api/bookings/{bookingId}/status
    // Body có thể truyền thêm customerUserId để hệ thống tự gửi thông báo
    // Nếu TV4 không truyền customerUserId thì vẫn chạy bình thường, chỉ không gửi thông báo
    @PostMapping("/{bookingId}/status")
    public ResponseEntity<BookingStatusLogResponse> updateStatus(
            @PathVariable Integer bookingId,
            @RequestBody BookingStatusLogRequest request
    ) {
        BookingStatusLog log = bookingStatusLogService.logStatusChange(
                bookingId,
                null,
                request.getNewStatus(),
                request.getNote(),
                request.getCustomerUserId()  // nullable — TV4 truyền vào nếu có
        );

        return ResponseEntity.ok(new BookingStatusLogResponse(log));
    }
}