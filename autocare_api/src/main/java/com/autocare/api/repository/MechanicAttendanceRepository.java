package com.autocare.api.repository;

import com.autocare.api.entity.MechanicAttendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface MechanicAttendanceRepository extends JpaRepository<MechanicAttendance, Integer> {
    Optional<MechanicAttendance> findByMechanicIdAndWorkDate(Integer mechanicId, LocalDate workDate);
}