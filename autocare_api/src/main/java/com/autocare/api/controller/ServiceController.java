package com.autocare.api.controller;

import com.autocare.api.dto.service.ServiceDTO;
import com.autocare.api.service.ServiceCatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Man hinh 2: "Chon dich vu sua chua" (ca 2 tab Den Garage / Tan noi). */
@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
public class ServiceController {

    private final ServiceCatalogService serviceCatalogService;

    @GetMapping
    public List<ServiceDTO> getServices(
            @RequestParam(name = "homeOnly", defaultValue = "false") boolean homeOnly) {
        return serviceCatalogService.getServices(homeOnly);
    }
}

