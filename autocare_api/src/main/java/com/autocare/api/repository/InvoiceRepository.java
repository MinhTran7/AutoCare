package com.autocare.api.repository;

import com.autocare.api.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface InvoiceRepository extends JpaRepository<Invoice, Integer> {

    // Tìm hoá đơn theo bookingId
    Optional<Invoice> findByBookingId(Integer bookingId);

    // Tìm hoá đơn theo mã hoá đơn
    Optional<Invoice> findByInvoiceCode(String invoiceCode);

    // Lấy tất cả hoá đơn của một user (qua bookingId list)
    List<Invoice> findByBookingIdIn(List<Integer> bookingIds);

    // Lấy hoá đơn theo trạng thái thanh toán
    List<Invoice> findByStatus(String status);

    // Kiểm tra booking đã có hoá đơn chưa
    boolean existsByBookingId(Integer bookingId);
}