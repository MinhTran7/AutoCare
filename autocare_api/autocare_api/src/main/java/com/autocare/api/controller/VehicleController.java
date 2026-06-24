package com.autocare.api.controller;

import com.autocare.api.dto.vehicle.VehicleRequest;
import com.autocare.api.dto.vehicle.VehicleResponse;
import com.autocare.api.service.VehicleService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/vehicles")
@CrossOrigin("*")
public class VehicleController {

    private final VehicleService vehicleService;

    public VehicleController(VehicleService vehicleService) {
        this.vehicleService = vehicleService;
    }

    @GetMapping
    public ResponseEntity<List<VehicleResponse>> getMyVehicles() {
        List<VehicleResponse> vehicles = vehicleService.getMyVehicles();
        return ResponseEntity.ok(vehicles);
    }

    @PostMapping
    public ResponseEntity<VehicleResponse> createVehicle(
            @RequestBody VehicleRequest request
    ) {
        VehicleResponse response = vehicleService.createVehicle(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<VehicleResponse> getMyVehicleById(
            @PathVariable Integer id
    ) {
        VehicleResponse response = vehicleService.getMyVehicleById(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<VehicleResponse> updateVehicle(
            @PathVariable Integer id,
            @RequestBody VehicleRequest request
    ) {
        VehicleResponse response = vehicleService.updateVehicle(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteVehicle(
            @PathVariable Integer id
    ) {
        vehicleService.deleteVehicle(id);

        return ResponseEntity.ok(
                Map.of("message", "Xóa xe thành công")
        );
    }

    @PatchMapping("/{id}/default")
    public ResponseEntity<VehicleResponse> setDefaultVehicle(
            @PathVariable Integer id
    ) {
        VehicleResponse response = vehicleService.setDefaultVehicle(id);
        return ResponseEntity.ok(response);
    }
}