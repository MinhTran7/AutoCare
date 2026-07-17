package com.autocare.api.controller;

import com.autocare.api.dto.admin.GarageResponse;
import com.autocare.api.service.AdminGarageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/garages")
@RequiredArgsConstructor
public class AdminGarageController {

    private final AdminGarageService adminGarageService;

    @GetMapping
    public ResponseEntity<List<GarageResponse>> getAll() {
        return ResponseEntity.ok(adminGarageService.getAll());
    }
}
