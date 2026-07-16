package com.autocare.api.controller;

import com.autocare.api.dto.admin.ServiceItemRequest;
import com.autocare.api.dto.admin.ServiceItemResponse;
import com.autocare.api.service.AdminServiceCatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/services")
@RequiredArgsConstructor
public class AdminServiceController {

    private final AdminServiceCatalogService adminServiceCatalogService;

    @GetMapping
    public ResponseEntity<List<ServiceItemResponse>> getAll() {
        return ResponseEntity.ok(adminServiceCatalogService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ServiceItemResponse> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(adminServiceCatalogService.getById(id));
    }

    @PostMapping
    public ResponseEntity<ServiceItemResponse> create(@RequestBody ServiceItemRequest request) {
        return ResponseEntity.ok(adminServiceCatalogService.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ServiceItemResponse> update(
            @PathVariable Integer id,
            @RequestBody ServiceItemRequest request
    ) {
        return ResponseEntity.ok(adminServiceCatalogService.update(id, request));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<ServiceItemResponse> setStatus(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body
    ) {
        return ResponseEntity.ok(
                adminServiceCatalogService.setStatus(id, body.get("status"))
        );
    }
}
