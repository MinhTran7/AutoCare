package com.autocare.api.dto.service;

import lombok.*;
import java.math.BigDecimal;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ServiceDTO {
    private Integer id;
    private String name;
    private BigDecimal price;
    private Boolean isHomeService;
}

