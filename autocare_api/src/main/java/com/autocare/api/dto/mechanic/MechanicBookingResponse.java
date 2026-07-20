package com.autocare.api.dto.mechanic;

import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@Getter
@Setter
@Builder
public class MechanicBookingResponse {
    private Integer id;

    private String garageName;

    private String licensePlate;

    private LocalDate bookingDate;

    private LocalTime startTime;

    private String status;
}
