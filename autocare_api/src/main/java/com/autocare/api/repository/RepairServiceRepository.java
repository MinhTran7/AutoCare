package com.autocare.api.repository;

import com.autocare.api.entity.RepairService;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RepairServiceRepository extends JpaRepository<RepairService, Integer> {
    List<RepairService> findByStatus(RepairService.ServiceStatus status);
    List<RepairService> findByStatusAndIsHomeService(RepairService.ServiceStatus status, Boolean isHomeService);
}
