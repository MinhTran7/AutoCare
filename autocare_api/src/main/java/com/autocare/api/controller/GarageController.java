package com.autocare.api.controller;

import com.autocare.api.dto.garage.GarageDTO;
import com.autocare.api.service.GarageQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api/garages")
@RequiredArgsConstructor
public class GarageController {
    private final GarageQueryService garageQueryService;

    @GetMapping
    public List<GarageDTO> getGarages(
            @RequestParam(required = false) String serviceIds,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng) {
        List<Integer> ids = (serviceIds == null || serviceIds.isBlank())
                ? Collections.emptyList()
                : List.of(serviceIds.split(",")).stream().map(Integer::parseInt).toList();
        return garageQueryService.getGarages(ids, lat, lng);
    }
}