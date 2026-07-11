package com.autocare.api.service;

import com.autocare.api.dto.service.ServiceDTO;
import com.autocare.api.entity.RepairService;
import com.autocare.api.repository.RepairServiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ServiceCatalogService {

    private final RepairServiceRepository repairServiceRepository;

    /**
     * Man hinh 2: "Chon dich vu sua chua".
     * homeOnly = true  -> chi lay dich vu ho tro sua tan noi (man hinh "Dich vu tan noi")
     * homeOnly = false -> lay tat ca dich vu dang ACTIVE (man hinh "Den Garage")
     */
    public List<ServiceDTO> getServices(boolean homeOnly) {
        List<RepairService> services = homeOnly
                ? repairServiceRepository.findByStatusAndIsHomeService(RepairService.ServiceStatus.ACTIVE, true)
                : repairServiceRepository.findByStatus(RepairService.ServiceStatus.ACTIVE);

        return services.stream().map(this::toDto).toList();
    }

    private ServiceDTO toDto(RepairService s) {
        return ServiceDTO.builder()
                .id(s.getId())
                .name(s.getName())
                .price(s.getPrice())
                .isHomeService(s.getIsHomeService())
                .build();
    }
}

