package com.autocare.api.repository;

import com.autocare.api.entity.ServiceItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServiceItemRepository extends JpaRepository<ServiceItem, Integer> {
    List<ServiceItem> findAllByOrderByCreatedAtDesc();
}
