package com.autocare.api.controller;


import com.autocare.api.dto.garage.GarageDTO;
import com.autocare.api.service.GarageQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Man hinh 3: "Chon Garage". */
@RestController
@RequestMapping("/api/garages")
@RequiredArgsConstructor
public class GarageController {

    private final GarageQueryService garageQueryService;

    @GetMapping
    public List<GarageDTO> getGarages(
            @RequestParam(required = false) Integer serviceId,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng) {
        return garageQueryService.getGarages(serviceId, lat, lng);
    }
}

