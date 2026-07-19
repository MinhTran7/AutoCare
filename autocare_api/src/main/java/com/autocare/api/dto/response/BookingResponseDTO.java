package com.autocare.api.dto.response;
import com.autocare.api.dto.service.BookingItemDTO;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingResponseDTO {
    private Integer id;
    private String bookingCode;
    private String bookingType;
    private String status;
    private List<BookingItemDTO> items;
    private Integer garageId;        // MỚI
    private String garageName;
    private String garageAddress;
    private String vehicleInfo;
    private LocalDate bookingDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private String displayAddress;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private BigDecimal totalAmount;
    private LocalDateTime createdAt;
}