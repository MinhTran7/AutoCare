package com.autocare.api.dto.response;

import com.autocare.api.entity.Invoice;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class InvoiceResponse {

    private Integer id;
    private Integer bookingId;
    private String invoiceCode;
    private BigDecimal subtotal;
    private BigDecimal discount;
    private BigDecimal taxAmount;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private String status;
    private LocalDateTime paymentDate;
    private LocalDateTime paidAt;
    private String pdfUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public InvoiceResponse() {
    }

    public InvoiceResponse(Invoice invoice) {
        this.id            = invoice.getId();
        this.bookingId     = invoice.getBookingId();
        this.invoiceCode   = invoice.getInvoiceCode();
        this.subtotal      = invoice.getSubtotal();
        this.discount      = invoice.getDiscount();
        this.taxAmount     = invoice.getTaxAmount();
        this.totalAmount   = invoice.getTotalAmount();
        this.paymentMethod = invoice.getPaymentMethod();
        this.status        = invoice.getStatus();
        this.paymentDate   = invoice.getPaymentDate();
        this.paidAt        = invoice.getPaidAt();
        this.pdfUrl        = invoice.getPdfUrl();
        this.createdAt     = invoice.getCreatedAt();
        this.updatedAt     = invoice.getUpdatedAt();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getBookingId() { return bookingId; }
    public void setBookingId(Integer bookingId) { this.bookingId = bookingId; }

    public String getInvoiceCode() { return invoiceCode; }
    public void setInvoiceCode(String invoiceCode) { this.invoiceCode = invoiceCode; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getDiscount() { return discount; }
    public void setDiscount(BigDecimal discount) { this.discount = discount; }

    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }

    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }

    public String getPdfUrl() { return pdfUrl; }
    public void setPdfUrl(String pdfUrl) { this.pdfUrl = pdfUrl; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}