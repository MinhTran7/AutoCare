package com.autocare.api.repository;

import com.autocare.api.entity.Garage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GarageRepository extends JpaRepository<Garage, Integer> {
    List<Garage> findByStatus(Garage.GarageStatus status);

    List<Garage> findAllByOrderByNameAsc();
}
