package com.autocare.api.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponse {
    private Integer id;

    // Thông tin xe sửa chữa
    private Integer vehicleId;
    private String vehicleBrand;
    private String vehicleModel;
    private String licensePlate;

    // Thông tin khách hàng (chủ xe)
    private String customerName;
    private String customerPhone;

    // Thông tin Garage
    private Integer garageId;
    private String garageName;

    // Thông tin dịch vụ sửa chữa chính
    private Integer serviceId;
    private String serviceName;
    private BigDecimal servicePrice;

    // Thông tin khung giờ đặt lịch
    private LocalDate bookingDate;
    private LocalTime startTime;
    private LocalTime endTime;

    // Chi tiết hình thức đặt lịch
    private String bookingType; // 'GARAGE' hoặc 'HOME'
    private String serviceAddress;
    private BigDecimal latitude;
    private BigDecimal longitude;

    // Trạng thái lịch đặt
    private String status; // 'PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}