package com.autocare.api.dto.admin;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class DashboardSummaryResponse {
    private long totalBookingsInRange;
    private Map<String, Long> bookingsByStatus;
    private long homeJobsInProgress;
    private BigDecimal paidRevenue;
    private long totalCustomers;
    private long totalMechanics;
    private long lowStockCount;
    private List<LowStockItem> lowStockItems;

    public DashboardSummaryResponse() {
    }

    public long getTotalBookingsInRange() { return totalBookingsInRange; }
    public void setTotalBookingsInRange(long totalBookingsInRange) {
        this.totalBookingsInRange = totalBookingsInRange;
    }

    public Map<String, Long> getBookingsByStatus() { return bookingsByStatus; }
    public void setBookingsByStatus(Map<String, Long> bookingsByStatus) {
        this.bookingsByStatus = bookingsByStatus;
    }

    public long getHomeJobsInProgress() { return homeJobsInProgress; }
    public void setHomeJobsInProgress(long homeJobsInProgress) {
        this.homeJobsInProgress = homeJobsInProgress;
    }

    public BigDecimal getPaidRevenue() { return paidRevenue; }
    public void setPaidRevenue(BigDecimal paidRevenue) {
        this.paidRevenue = paidRevenue;
    }

    public long getTotalCustomers() { return totalCustomers; }
    public void setTotalCustomers(long totalCustomers) {
        this.totalCustomers = totalCustomers;
    }

    public long getTotalMechanics() { return totalMechanics; }
    public void setTotalMechanics(long totalMechanics) {
        this.totalMechanics = totalMechanics;
    }

    public long getLowStockCount() { return lowStockCount; }
    public void setLowStockCount(long lowStockCount) {
        this.lowStockCount = lowStockCount;
    }

    public List<LowStockItem> getLowStockItems() { return lowStockItems; }
    public void setLowStockItems(List<LowStockItem> lowStockItems) {
        this.lowStockItems = lowStockItems;
    }

    public static class LowStockItem {
        private Integer id;
        private String partName;
        private Integer quantityInStock;
        private Integer minStockLevel;

        public LowStockItem() {
        }

        public LowStockItem(Integer id, String partName, Integer quantityInStock, Integer minStockLevel) {
            this.id = id;
            this.partName = partName;
            this.quantityInStock = quantityInStock;
            this.minStockLevel = minStockLevel;
        }

        public Integer getId() { return id; }
        public String getPartName() { return partName; }
        public Integer getQuantityInStock() { return quantityInStock; }
        public Integer getMinStockLevel() { return minStockLevel; }
    }
}
