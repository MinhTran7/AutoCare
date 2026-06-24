package com.autocare.api.service;

import com.autocare.api.dto.vehicle.VehicleRequest;
import com.autocare.api.dto.vehicle.VehicleResponse;
import com.autocare.api.entity.User;
import com.autocare.api.entity.Vehicle;
import com.autocare.api.entity.VehicleStatus;
import com.autocare.api.repository.UserRepository;
import com.autocare.api.repository.VehicleRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.Year;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class VehicleService {

    private final VehicleRepository vehicleRepository;
    private final UserRepository userRepository;

    public VehicleService(
            VehicleRepository vehicleRepository,
            UserRepository userRepository
    ) {
        this.vehicleRepository = vehicleRepository;
        this.userRepository = userRepository;
    }

    public List<VehicleResponse> getMyVehicles() {
        User currentUser = getCurrentUser();

        return vehicleRepository
                .findByUserAndStatusOrderByCreatedAtDesc(
                        currentUser,
                        VehicleStatus.ACTIVE
                )
                .stream()
                .map(VehicleResponse::new)
                .collect(Collectors.toList());
    }

    public VehicleResponse getMyVehicleById(Integer id) {
        User currentUser = getCurrentUser();

        Vehicle vehicle = vehicleRepository
                .findByIdAndUserAndStatus(
                        id,
                        currentUser,
                        VehicleStatus.ACTIVE
                )
                .orElseThrow(() -> new RuntimeException("Không tìm thấy xe"));

        return new VehicleResponse(vehicle);
    }

    public VehicleResponse createVehicle(VehicleRequest request) {
        User currentUser = getCurrentUser();

        validateVehicleRequest(request);

        String licensePlate = normalize(request.getLicensePlate());

        boolean plateExists = vehicleRepository
                .findByUserAndLicensePlateAndStatus(
                        currentUser,
                        licensePlate,
                        VehicleStatus.ACTIVE
                )
                .isPresent();

        if (plateExists) {
            throw new RuntimeException("Biển số xe đã tồn tại trong Garage của bạn");
        }

        List<Vehicle> activeVehicles = vehicleRepository
                .findByUserAndStatusOrderByCreatedAtDesc(
                        currentUser,
                        VehicleStatus.ACTIVE
                );

        boolean isFirstVehicle = activeVehicles.isEmpty();
        boolean shouldBeDefault = Boolean.TRUE.equals(request.getIsDefault()) || isFirstVehicle;

        if (shouldBeDefault) {
            clearDefaultVehicle(currentUser);
        }

        Vehicle vehicle = new Vehicle();
        vehicle.setUser(currentUser);
        vehicle.setVehicleType(normalize(request.getVehicleType()));
        vehicle.setBrand(normalize(request.getBrand()));
        vehicle.setModel(normalize(request.getModel()));
        vehicle.setLicensePlate(licensePlate);
        vehicle.setManufacturingYear(request.getManufacturingYear());
        vehicle.setColor(normalizeNullable(request.getColor()));
        vehicle.setMileage(request.getMileage());
        vehicle.setIsDefault(shouldBeDefault);
        vehicle.setStatus(VehicleStatus.ACTIVE);

        Vehicle savedVehicle = vehicleRepository.save(vehicle);

        return new VehicleResponse(savedVehicle);
    }

    public VehicleResponse updateVehicle(Integer id, VehicleRequest request) {
        User currentUser = getCurrentUser();

        validateVehicleRequest(request);

        Vehicle vehicle = vehicleRepository
                .findByIdAndUserAndStatus(
                        id,
                        currentUser,
                        VehicleStatus.ACTIVE
                )
                .orElseThrow(() -> new RuntimeException("Không tìm thấy xe"));

        String licensePlate = normalize(request.getLicensePlate());

        vehicleRepository
                .findByUserAndLicensePlateAndStatus(
                        currentUser,
                        licensePlate,
                        VehicleStatus.ACTIVE
                )
                .ifPresent(existingVehicle -> {
                    if (!existingVehicle.getId().equals(vehicle.getId())) {
                        throw new RuntimeException("Biển số xe đã tồn tại trong Garage của bạn");
                    }
                });

        vehicle.setVehicleType(normalize(request.getVehicleType()));
        vehicle.setBrand(normalize(request.getBrand()));
        vehicle.setModel(normalize(request.getModel()));
        vehicle.setLicensePlate(licensePlate);
        vehicle.setManufacturingYear(request.getManufacturingYear());
        vehicle.setColor(normalizeNullable(request.getColor()));
        vehicle.setMileage(request.getMileage());

        if (Boolean.TRUE.equals(request.getIsDefault())) {
            clearDefaultVehicle(currentUser);
            vehicle.setIsDefault(true);
        }

        Vehicle savedVehicle = vehicleRepository.save(vehicle);

        return new VehicleResponse(savedVehicle);
    }

    public void deleteVehicle(Integer id) {
        User currentUser = getCurrentUser();

        Vehicle vehicle = vehicleRepository
                .findByIdAndUserAndStatus(
                        id,
                        currentUser,
                        VehicleStatus.ACTIVE
                )
                .orElseThrow(() -> new RuntimeException("Không tìm thấy xe"));

        boolean wasDefault = Boolean.TRUE.equals(vehicle.getIsDefault());

        vehicle.setStatus(VehicleStatus.DELETED_BY_CUSTOMER);
        vehicle.setDeletedAt(LocalDateTime.now());
        vehicle.setIsDefault(false);

        vehicleRepository.save(vehicle);

        if (wasDefault) {
            setAnotherVehicleAsDefault(currentUser);
        }
    }

    public VehicleResponse setDefaultVehicle(Integer id) {
        User currentUser = getCurrentUser();

        Vehicle vehicle = vehicleRepository
                .findByIdAndUserAndStatus(
                        id,
                        currentUser,
                        VehicleStatus.ACTIVE
                )
                .orElseThrow(() -> new RuntimeException("Không tìm thấy xe"));

        clearDefaultVehicle(currentUser);

        vehicle.setIsDefault(true);

        Vehicle savedVehicle = vehicleRepository.save(vehicle);

        return new VehicleResponse(savedVehicle);
    }

    private void clearDefaultVehicle(User user) {
        List<Vehicle> defaultVehicles = vehicleRepository
                .findByUserAndStatusAndIsDefault(
                        user,
                        VehicleStatus.ACTIVE,
                        true
                );

        for (Vehicle vehicle : defaultVehicles) {
            vehicle.setIsDefault(false);
        }

        vehicleRepository.saveAll(defaultVehicles);
    }

    private void setAnotherVehicleAsDefault(User user) {
        List<Vehicle> activeVehicles = vehicleRepository
                .findByUserAndStatusOrderByCreatedAtDesc(
                        user,
                        VehicleStatus.ACTIVE
                );

        if (!activeVehicles.isEmpty()) {
            Vehicle nextDefaultVehicle = activeVehicles.get(0);
            nextDefaultVehicle.setIsDefault(true);
            vehicleRepository.save(nextDefaultVehicle);
        }
    }

    private void validateVehicleRequest(VehicleRequest request) {
        if (request == null) {
            throw new RuntimeException("Dữ liệu xe không hợp lệ");
        }

        if (isBlank(request.getVehicleType())) {
            throw new RuntimeException("Loại xe không được để trống");
        }

        if (isBlank(request.getBrand())) {
            throw new RuntimeException("Hãng xe không được để trống");
        }

        if (isBlank(request.getModel())) {
            throw new RuntimeException("Dòng xe không được để trống");
        }

        if (isBlank(request.getLicensePlate())) {
            throw new RuntimeException("Biển số xe không được để trống");
        }

        if (request.getManufacturingYear() != null) {
            int currentYear = Year.now().getValue();

            if (request.getManufacturingYear() < 1900 ||
                    request.getManufacturingYear() > currentYear + 1) {
                throw new RuntimeException("Năm sản xuất không hợp lệ");
            }
        }

        if (request.getMileage() != null && request.getMileage() < 0) {
            throw new RuntimeException("Số km đã đi không hợp lệ");
        }
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("Bạn chưa đăng nhập");
        }

        String emailOrPhone = authentication.getName();

        return userRepository
                .findByEmailOrPhone(emailOrPhone, emailOrPhone)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String normalize(String value) {
        return value.trim();
    }

    private String normalizeNullable(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return value.trim();
    }
}