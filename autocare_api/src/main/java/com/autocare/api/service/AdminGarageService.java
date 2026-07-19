package com.autocare.api.service;

import com.autocare.api.dto.admin.GarageRequest;
import com.autocare.api.dto.admin.GarageResponse;
import com.autocare.api.entity.Garage;
import com.autocare.api.repository.GarageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminGarageService {

    /** Soft-delete marker — không thêm cột/enum mới, không xóa dòng DB */
    private static final String DELETED_MARKER = "[DELETED] ";

    private final GarageRepository garageRepository;

    public List<GarageResponse> getAll() {
        ensureSeedData();
        // Hiện ACTIVE + INACTIVE; ẩn garage đã soft-delete (name có marker)
        return garageRepository.findAllByOrderByNameAsc()
                .stream()
                .filter(g -> !isSoftDeleted(g))
                .map(GarageResponse::new)
                .collect(Collectors.toList());
    }

    public GarageResponse getById(Integer id) {
        Garage garage = getEntity(id);
        if (isSoftDeleted(garage)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy garage");
        }
        return new GarageResponse(garage);
    }

    public GarageResponse create(GarageRequest request) {
        validate(request, true);

        LocalDateTime now = LocalDateTime.now();
        Garage garage = Garage.builder()
                .name(request.getName().trim())
                .address(normalize(request.getAddress()))
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .status(parseStatus(request.getStatus()))
                .createdAt(now)
                .updatedAt(now)
                .build();

        return new GarageResponse(garageRepository.save(garage));
    }

    public GarageResponse update(Integer id, GarageRequest request) {
        validate(request, false);

        Garage garage = getEntity(id);
        if (isSoftDeleted(garage)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy garage");
        }
        garage.setName(request.getName().trim());
        garage.setAddress(normalize(request.getAddress()));
        garage.setLatitude(request.getLatitude());
        garage.setLongitude(request.getLongitude());
        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            garage.setStatus(parseStatus(request.getStatus()));
        }
        garage.setUpdatedAt(LocalDateTime.now());

        return new GarageResponse(garageRepository.save(garage));
    }

    public GarageResponse setStatus(Integer id, String status) {
        Garage garage = getEntity(id);
        if (isSoftDeleted(garage)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Không tìm thấy garage");
        }
        // Toggle chỉ ACTIVE <-> INACTIVE; garage INACTIVE vẫn còn trên list
        garage.setStatus(parseStatus(status));
        garage.setUpdatedAt(LocalDateTime.now());
        return new GarageResponse(garageRepository.save(garage));
    }

    public void delete(Integer id) {
        Garage garage = getEntity(id);
        if (isSoftDeleted(garage)) {
            return;
        }
        // Soft delete: đánh dấu name + INACTIVE — không xóa dòng, không đổi schema
        garage.setName(DELETED_MARKER + garage.getName());
        garage.setStatus(Garage.GarageStatus.INACTIVE);
        garage.setUpdatedAt(LocalDateTime.now());
        garageRepository.save(garage);
    }

    private boolean isSoftDeleted(Garage garage) {
        String name = garage.getName();
        return name != null && name.startsWith(DELETED_MARKER);
    }

    private Garage getEntity(Integer id) {
        return garageRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy garage"
                ));
    }

    private void validate(GarageRequest request, boolean creating) {
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ");
        }
        if (request.getName() == null || request.getName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tên garage không được để trống");
        }
        if (request.getName().trim().startsWith(DELETED_MARKER)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tên garage không hợp lệ");
        }
        if (creating && (request.getStatus() == null || request.getStatus().isBlank())) {
            request.setStatus("ACTIVE");
        }
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private Garage.GarageStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return Garage.GarageStatus.ACTIVE;
        }
        String normalized = status.trim().toUpperCase();
        if (!normalized.equals("ACTIVE") && !normalized.equals("INACTIVE")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status phải là ACTIVE hoặc INACTIVE");
        }
        return Garage.GarageStatus.valueOf(normalized);
    }

    private void ensureSeedData() {
        if (garageRepository.count() > 0) {
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        garageRepository.save(Garage.builder()
                .name("AutoCare Quận 1")
                .address("12 Nguyễn Huệ, Quận 1, TP.HCM")
                .status(Garage.GarageStatus.ACTIVE)
                .createdAt(now)
                .updatedAt(now)
                .build());

        garageRepository.save(Garage.builder()
                .name("AutoCare Thủ Đức")
                .address("45 Võ Văn Ngân, Thủ Đức, TP.HCM")
                .status(Garage.GarageStatus.ACTIVE)
                .createdAt(now)
                .updatedAt(now)
                .build());
    }
}
