package com.autocare.api.controller;

import com.autocare.api.dto.admin.CustomerAccountResponse;
import com.autocare.api.dto.admin.UpdateMechanicStatusRequest;
import com.autocare.api.service.AdminCustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/customers")
@RequiredArgsConstructor
public class AdminCustomerController {

    private final AdminCustomerService adminCustomerService;

    @GetMapping
    public ResponseEntity<List<CustomerAccountResponse>> getAll() {
        return ResponseEntity.ok(adminCustomerService.getAllCustomers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CustomerAccountResponse> getDetail(@PathVariable Integer id) {
        return ResponseEntity.ok(adminCustomerService.getCustomerDetail(id));
    }

    @PatchMapping("/{id}/lock")
    public ResponseEntity<CustomerAccountResponse> lock(
            @PathVariable Integer id,
            @RequestBody(required = false) UpdateMechanicStatusRequest request
    ) {
        return ResponseEntity.ok(adminCustomerService.lockCustomer(id, request));
    }

    @PatchMapping("/{id}/unlock")
    public ResponseEntity<CustomerAccountResponse> unlock(@PathVariable Integer id) {
        return ResponseEntity.ok(adminCustomerService.unlockCustomer(id));
    }
}
