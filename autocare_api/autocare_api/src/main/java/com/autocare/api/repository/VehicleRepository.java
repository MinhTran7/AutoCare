package com.autocare.api.repository;

import com.autocare.api.entity.User;
import com.autocare.api.entity.Vehicle;
import com.autocare.api.entity.VehicleStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VehicleRepository extends JpaRepository<Vehicle, Integer> {

    List<Vehicle> findByUserAndStatusOrderByCreatedAtDesc(
            User user,
            VehicleStatus status
    );

    Optional<Vehicle> findByIdAndUserAndStatus(
            Integer id,
            User user,
            VehicleStatus status
    );

    Optional<Vehicle> findByUserAndLicensePlateAndStatus(
            User user,
            String licensePlate,
            VehicleStatus status
    );

    List<Vehicle> findByUserAndStatusAndIsDefault(
            User user,
            VehicleStatus status,
            Boolean isDefault
    );
}