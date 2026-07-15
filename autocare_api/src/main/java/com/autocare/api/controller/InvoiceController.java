package com.autocare.api.controller;

import com.autocare.api.dto.request.InvoiceRequest;
import com.autocare.api.dto.response.InvoiceResponse;
import com.autocare.api.entity.Invoice;
import com.autocare.api.service.InvoiceService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/invoices")
@CrossOrigin("*")
public class InvoiceController {

    private final InvoiceService invoiceService;

    public InvoiceController(InvoiceService invoiceService) {
        this.invoiceService = invoiceService;
    }

    // GET /api/invoices/booking/{bookingId}
    // Lấy hoá đơn theo bookingId
    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<InvoiceResponse> getByBookingId(
            @PathVariable Integer bookingId
    ) {
        Invoice invoice = invoiceService.getByBookingId(bookingId);
        return ResponseEntity.ok(new InvoiceResponse(invoice));
    }

    // GET /api/invoices/code/{invoiceCode}
    // Lấy hoá đơn theo mã INV-YYYYMMDD-XXXX
    @GetMapping("/code/{invoiceCode}")
    public ResponseEntity<InvoiceResponse> getByInvoiceCode(
            @PathVariable String invoiceCode
    ) {
        Invoice invoice = invoiceService.getByInvoiceCode(invoiceCode);
        return ResponseEntity.ok(new InvoiceResponse(invoice));
    }

    // POST /api/invoices
    // Tạo hoá đơn mới sau khi booking hoàn thành
    @PostMapping
    public ResponseEntity<InvoiceResponse> createInvoice(
            @RequestBody InvoiceRequest request
    ) {
        Invoice invoice = invoiceService.createInvoice(
                request.getBookingId(),
                request.getSubtotal(),
                request.getDiscount(),
                request.getTaxAmount(),
                request.getPaymentMethod()
        );
        return ResponseEntity.ok(new InvoiceResponse(invoice));
    }

    // PATCH /api/invoices/booking/{bookingId}/pay
    // Đánh dấu hoá đơn đã thanh toán
    @PatchMapping("/booking/{bookingId}/pay")
    public ResponseEntity<InvoiceResponse> markAsPaid(
            @PathVariable Integer bookingId,
            @RequestBody Map<String, String> body
    ) {
        String paymentMethod = body.get("paymentMethod");
        Invoice invoice = invoiceService.markAsPaid(bookingId, paymentMethod);
        return ResponseEntity.ok(new InvoiceResponse(invoice));
    }

    // PATCH /api/invoices/booking/{bookingId}/cancel
    // Huỷ hoá đơn
    @PatchMapping("/booking/{bookingId}/cancel")
    public ResponseEntity<InvoiceResponse> cancelInvoice(
            @PathVariable Integer bookingId
    ) {
        Invoice invoice = invoiceService.cancelInvoice(bookingId);
        return ResponseEntity.ok(new InvoiceResponse(invoice));
    }
}