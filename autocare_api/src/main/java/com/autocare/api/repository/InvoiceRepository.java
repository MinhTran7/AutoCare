package com.autocare.api.repository;

import com.autocare.api.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface InvoiceRepository extends JpaRepository<Invoice, Integer> {

    Optional<Invoice> findByBookingId(Integer bookingId);

    Optional<Invoice> findByInvoiceCode(String invoiceCode);

    List<Invoice> findByBookingIdIn(List<Integer> bookingIds);

    List<Invoice> findByStatus(String status);

    boolean existsByBookingId(Integer bookingId);

    @Query("""
            SELECT COALESCE(SUM(i.totalAmount), 0)
            FROM Invoice i
            WHERE i.status = 'PAID'
              AND i.paidAt IS NOT NULL
              AND i.paidAt BETWEEN :from AND :to
            """)
    BigDecimal sumPaidAmountBetween(
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );
}
