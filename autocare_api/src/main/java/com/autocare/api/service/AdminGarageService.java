package com.autocare.api.service;

import com.autocare.api.dto.admin.GarageResponse;
import com.autocare.api.entity.Garage;
import com.autocare.api.repository.GarageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminGarageService {

    private final GarageRepository garageRepository;

    public List<GarageResponse> getAll() {
        ensureSeedData();
        return garageRepository.findAllByOrderByNameAsc()
                .stream()
                .map(GarageResponse::new)
                .collect(Collectors.toList());
    }

    private void ensureSeedData() {
        if (garageRepository.count() > 0) {
            return;
        }

        garageRepository.save(Garage.builder()
                .name("AutoCare Quận 1")
                .address("12 Nguyễn Huệ, Quận 1, TP.HCM")
                .phone("02811112222")
                .status("ACTIVE")
                .build());

        garageRepository.save(Garage.builder()
                .name("AutoCare Thủ Đức")
                .address("45 Võ Văn Ngân, Thủ Đức, TP.HCM")
                .phone("02833334444")
                .status("ACTIVE")
                .build());
    }
}
