package com.autocare.api.controller;

import com.autocare.api.dto.admin.SparePartRequest;
import com.autocare.api.dto.admin.SparePartResponse;
import com.autocare.api.dto.admin.StockAdjustRequest;
import com.autocare.api.service.AdminSparePartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/spare-parts")
@RequiredArgsConstructor
public class AdminSparePartController {

    private final AdminSparePartService adminSparePartService;

    @GetMapping
    public ResponseEntity<List<SparePartResponse>> getAll() {
        return ResponseEntity.ok(adminSparePartService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<SparePartResponse> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(adminSparePartService.getById(id));
    }

    @PostMapping
    public ResponseEntity<SparePartResponse> create(@RequestBody SparePartRequest request) {
        return ResponseEntity.ok(adminSparePartService.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<SparePartResponse> update(
            @PathVariable Integer id,
            @RequestBody SparePartRequest request
    ) {
        return ResponseEntity.ok(adminSparePartService.update(id, request));
    }

    @PatchMapping("/{id}/stock")
    public ResponseEntity<SparePartResponse> adjustStock(
            @PathVariable Integer id,
            @RequestBody StockAdjustRequest request
    ) {
        return ResponseEntity.ok(adminSparePartService.adjustStock(id, request));
    }
}
