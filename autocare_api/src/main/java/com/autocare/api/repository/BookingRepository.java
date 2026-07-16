package com.autocare.api.repository;

import com.autocare.api.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Integer> {
    List<Booking> findByVehicle_UserIdOrderByCreatedAtDesc(Integer userId);
}
