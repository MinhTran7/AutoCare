package com.autocare.api.dto.service;

import lombok.*;
import java.time.LocalTime;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SlotDTO {
    private Integer id;
    private LocalTime startTime;
    private LocalTime endTime;
    private String status; // AVAILABLE / BOOKED / CANCELLED
}

