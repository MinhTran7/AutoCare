package com.autocare.api.repository;

import com.autocare.api.entity.Mechanic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MechanicRepository extends JpaRepository<Mechanic, Integer> {
    Optional<Mechanic> findByUserId(Integer userId);
}