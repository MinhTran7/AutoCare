package com.autocare.api.repository;

import com.autocare.api.entity.Mechanic;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MechanicRepository extends JpaRepository<Mechanic, Integer> {
    List<Mechanic> findByGarage_IdAndStatus(Integer garageId, Mechanic.MechanicStatus status);
}
