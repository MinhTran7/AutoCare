package com.autocare.api.service;

import com.autocare.api.dto.admin.ServiceItemRequest;
import com.autocare.api.dto.admin.ServiceItemResponse;
import com.autocare.api.entity.RepairService;
import com.autocare.api.repository.RepairServiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminServiceCatalogService {

    private final RepairServiceRepository repairServiceRepository;

    public List<ServiceItemResponse> getAll() {
        return repairServiceRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(ServiceItemResponse::new)
                .collect(Collectors.toList());
    }

    public ServiceItemResponse getById(Integer id) {
        return new ServiceItemResponse(getEntity(id));
    }

    public ServiceItemResponse create(ServiceItemRequest request) {
        validate(request, true);

        RepairService item = RepairService.builder()
                .name(request.getName().trim())
                .description(normalize(request.getDescription()))
                .price(request.getPrice())
                .isHomeService(Boolean.TRUE.equals(request.getIsHomeService()))
                .status(parseStatus(request.getStatus()))
                .build();

        return new ServiceItemResponse(repairServiceRepository.save(item));
    }

    public ServiceItemResponse update(Integer id, ServiceItemRequest request) {
        validate(request, false);

        RepairService item = getEntity(id);
        item.setName(request.getName().trim());
        item.setDescription(normalize(request.getDescription()));
        item.setPrice(request.getPrice());
        if (request.getIsHomeService() != null) {
            item.setIsHomeService(request.getIsHomeService());
        }
        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            item.setStatus(parseStatus(request.getStatus()));
        }

        return new ServiceItemResponse(repairServiceRepository.save(item));
    }

    public ServiceItemResponse setStatus(Integer id, String status) {
        RepairService item = getEntity(id);
        item.setStatus(parseStatus(status));
        return new ServiceItemResponse(repairServiceRepository.save(item));
    }

    private RepairService getEntity(Integer id) {
        return repairServiceRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy dịch vụ"
                ));
    }

    private void validate(ServiceItemRequest request, boolean creating) {
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ");
        }
        if (request.getName() == null || request.getName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tên dịch vụ không được để trống");
        }
        if (request.getPrice() == null || request.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Giá dịch vụ không hợp lệ");
        }
        if (creating && request.getStatus() == null) {
            request.setStatus("ACTIVE");
        }
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private RepairService.ServiceStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return RepairService.ServiceStatus.ACTIVE;
        }
        String normalized = status.trim().toUpperCase();
        try {
            return RepairService.ServiceStatus.valueOf(normalized);
        } catch (IllegalArgumentException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status phải là ACTIVE hoặc INACTIVE");
        }
    }
}
