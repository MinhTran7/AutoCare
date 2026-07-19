package com.autocare.api.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingRequestDTO {
    @NotNull(message = "vehicleId khong duoc de trong")
    private Integer vehicleId;

    @NotNull(message = "garageId khong duoc de trong")
    private Integer garageId;

    @NotEmpty(message = "Vui long chon it nhat 1 dich vu")
    private List<Integer> serviceIds;

    @NotNull(message = "slotId khong duoc de trong")
    private Integer slotId;

    @NotNull(message = "bookingType khong duoc de trong")
    private String bookingType;

    private String serviceAddress;
    private BigDecimal latitude;
    private BigDecimal longitude;
}