package com.autocare.api.controller;

import com.autocare.api.dto.admin.CreateMechanicRequest;
import com.autocare.api.dto.admin.MechanicAccountResponse;
import com.autocare.api.dto.admin.UpdateMechanicRequest;
import com.autocare.api.dto.admin.UpdateMechanicStatusRequest;
import com.autocare.api.service.AdminMechanicService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/mechanics")
@RequiredArgsConstructor
public class AdminMechanicController {

    private final AdminMechanicService adminMechanicService;

    @PostMapping
    public ResponseEntity<MechanicAccountResponse> createMechanic(
            @RequestBody CreateMechanicRequest request
    ) {
        return ResponseEntity.ok(
                adminMechanicService.createMechanic(request)
        );
    }

    @GetMapping
    public ResponseEntity<List<MechanicAccountResponse>> getAllMechanics() {
        return ResponseEntity.ok(
                adminMechanicService.getAllMechanics()
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<MechanicAccountResponse> getMechanicDetail(
            @PathVariable Integer id
    ) {
        return ResponseEntity.ok(
                adminMechanicService.getMechanicDetail(id)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<MechanicAccountResponse> updateMechanic(
            @PathVariable Integer id,
            @RequestBody UpdateMechanicRequest request
    ) {
        return ResponseEntity.ok(
                adminMechanicService.updateMechanic(id, request)
        );
    }

    @PatchMapping("/{id}/lock")
    public ResponseEntity<MechanicAccountResponse> lockMechanic(
            @PathVariable Integer id,
            @RequestBody(required = false) UpdateMechanicStatusRequest request
    ) {
        return ResponseEntity.ok(
                adminMechanicService.lockMechanic(id, request)
        );
    }

    @PatchMapping("/{id}/unlock")
    public ResponseEntity<MechanicAccountResponse> unlockMechanic(
            @PathVariable Integer id
    ) {
        return ResponseEntity.ok(
                adminMechanicService.unlockMechanic(id)
        );
    }
}