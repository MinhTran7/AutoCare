package com.autocare.api.repository;

import com.autocare.api.entity.GarageServiceLink;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface GarageServiceLinkRepository extends JpaRepository<GarageServiceLink, Integer> {

    List<GarageServiceLink> findByService_Id(Integer serviceId);

    List<GarageServiceLink> findByGarage_Id(Integer garageId);

    boolean existsByGarage_IdAndService_Id(Integer garageId, Integer serviceId);
}
