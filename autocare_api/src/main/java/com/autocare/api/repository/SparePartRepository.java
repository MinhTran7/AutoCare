package com.autocare.api.repository;

import com.autocare.api.entity.SparePart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface SparePartRepository extends JpaRepository<SparePart, Integer> {
    List<SparePart> findAllByOrderByPartNameAsc();

    @Query("SELECT s FROM SparePart s WHERE s.quantityInStock <= s.minStockLevel")
    List<SparePart> findLowStock();
}
