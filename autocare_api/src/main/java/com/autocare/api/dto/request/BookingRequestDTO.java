package com.autocare.api.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.math.BigDecimal;

/** Du lieu FE gui len khi nguoi dung bam "Dat lich" o man hinh 6. */
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingRequestDTO {

    @NotNull(message = "vehicleId khong duoc de trong")
    private Integer vehicleId;

    @NotNull(message = "garageId khong duoc de trong")
    private Integer garageId;

    @NotNull(message = "serviceId khong duoc de trong")
    private Integer serviceId;

    @NotNull(message = "slotId khong duoc de trong")
    private Integer slotId;

    @NotNull(message = "bookingType khong duoc de trong")
    private String bookingType; // GARAGE hoac HOME

    // Chi bat buoc khi bookingType = HOME (man hinh 5A "Chon dia diem sua chua")
    private String serviceAddress;
    private BigDecimal latitude;
    private BigDecimal longitude;
}

