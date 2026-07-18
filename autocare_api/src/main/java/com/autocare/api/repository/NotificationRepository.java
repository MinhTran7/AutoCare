package com.autocare.api.repository;

import com.autocare.api.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    // Dùng user.id thay vì userId (vì Entity dùng @ManyToOne User)
    List<Notification> findByUser_IdOrderByCreatedAtDesc(Integer userId);

    List<Notification> findByUser_IdAndIsReadFalseOrderByCreatedAtDesc(Integer userId);

    long countByUser_IdAndIsReadFalse(Integer userId);

    List<Notification> findByUser_IdAndTypeOrderByCreatedAtDesc(Integer userId, String type);

    List<Notification> findByBooking_IdOrderByCreatedAtDesc(Integer bookingId);
}