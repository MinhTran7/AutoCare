package com.autocare.api.dto.garage;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class GarageDTO {
    private Integer id;
    private String name;
    private String address;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private Double distanceKm;
}

