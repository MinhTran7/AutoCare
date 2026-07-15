package com.autocare.api.repository;

import com.autocare.api.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    // Lấy tất cả thông báo của user, mới nhất lên trước
    List<Notification> findByUserIdOrderByCreatedAtDesc(Integer userId);

    // Lấy thông báo chưa đọc của user
    List<Notification> findByUserIdAndIsReadFalseOrderByCreatedAtDesc(Integer userId);

    // Đếm số thông báo chưa đọc → hiển thị badge trên app
    long countByUserIdAndIsReadFalse(Integer userId);

    // Lấy thông báo theo loại
    List<Notification> findByUserIdAndTypeOrderByCreatedAtDesc(Integer userId, String type);

    // Lấy thông báo liên quan đến 1 booking
    List<Notification> findByBookingIdOrderByCreatedAtDesc(Integer bookingId);
}