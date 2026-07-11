package com.autocare.api.dto.response;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/** Du lieu tra ve o man hinh 6 (Xac nhan) va man hinh 7 (Dat lich thanh cong). */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingResponseDTO {
    private Integer id;
    private String bookingCode;      // vd: DL2406289
    private String bookingType;      // GARAGE / HOME
    private String status;

    private String serviceName;
    private BigDecimal servicePrice;

    private String garageName;
    private String garageAddress;

    private String vehicleInfo;      // vd: Toyota Vios - 30A-12345

    private LocalDate bookingDate;
    private LocalTime startTime;
    private LocalTime endTime;

    private String displayAddress;   // dia chi hien thi o man hinh xac nhan/thanh cong
    private BigDecimal latitude;
    private BigDecimal longitude;

    private BigDecimal totalAmount;
    private LocalDateTime createdAt;
}

