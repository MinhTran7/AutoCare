package com.autocare.api.controller;

import com.autocare.api.dto.admin.GarageRequest;
import com.autocare.api.dto.admin.GarageResponse;
import com.autocare.api.service.AdminGarageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/garages")
@RequiredArgsConstructor
public class AdminGarageController {

    private final AdminGarageService adminGarageService;

    @GetMapping
    public ResponseEntity<List<GarageResponse>> getAll() {
        return ResponseEntity.ok(adminGarageService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<GarageResponse> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(adminGarageService.getById(id));
    }

    @PostMapping
    public ResponseEntity<GarageResponse> create(@RequestBody GarageRequest request) {
        return ResponseEntity.ok(adminGarageService.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<GarageResponse> update(
            @PathVariable Integer id,
            @RequestBody GarageRequest request
    ) {
        return ResponseEntity.ok(adminGarageService.update(id, request));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<GarageResponse> setStatus(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body
    ) {
        return ResponseEntity.ok(adminGarageService.setStatus(id, body.get("status")));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        adminGarageService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
