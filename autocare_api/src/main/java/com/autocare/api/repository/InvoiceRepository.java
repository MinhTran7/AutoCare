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

    // TV3 — tìm theo booking
    Optional<Invoice> findByBooking_Id(Integer bookingId);

    Optional<Invoice> findByInvoiceCode(String invoiceCode);

    List<Invoice> findByBooking_IdIn(List<Integer> bookingIds);

    List<Invoice> findByStatus(String status);

    boolean existsByBooking_Id(Integer bookingId);

    // TV5 — Admin Dashboard: tổng doanh thu trong khoảng thời gian
    @Query("SELECT COALESCE(SUM(i.totalAmount), 0) FROM Invoice i " +
            "WHERE i.paidAt BETWEEN :from AND :to AND i.status = 'PAID'")
    BigDecimal sumPaidAmountBetween(
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );
}