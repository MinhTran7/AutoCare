package com.autocare.api.dto.service;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class BookingItemDTO {
    private Integer serviceId;
    private String serviceName;
    private BigDecimal price;
}