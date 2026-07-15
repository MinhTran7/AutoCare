package com.autocare.api.controller;

import com.autocare.api.service.MechanicService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/mechanics")
@RequiredArgsConstructor
public class MechanicController {

    private final MechanicService mechanicService;

    @GetMapping("/my-bookings")
    public ResponseEntity<?> getMyBookings(@RequestAttribute("userId") Integer userId) {
        return ResponseEntity.ok(mechanicService.getAssignedBookings(userId));
    }

    @PutMapping("/status")
    public ResponseEntity<?> updateMyStatus(@RequestAttribute("userId") Integer userId, @RequestParam String status) {
        mechanicService.updateStatus(userId, status);
        return ResponseEntity.ok("Status updated successfully");
    }
}