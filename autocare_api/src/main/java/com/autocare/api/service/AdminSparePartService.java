package com.autocare.api.service;

import com.autocare.api.dto.admin.SparePartRequest;
import com.autocare.api.dto.admin.SparePartResponse;
import com.autocare.api.dto.admin.StockAdjustRequest;
import com.autocare.api.entity.SparePart;
import com.autocare.api.repository.SparePartRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminSparePartService {

    private final SparePartRepository sparePartRepository;

    public List<SparePartResponse> getAll() {
        return sparePartRepository.findAllByOrderByPartNameAsc()
                .stream()
                .map(SparePartResponse::new)
                .collect(Collectors.toList());
    }

    public SparePartResponse getById(Integer id) {
        return new SparePartResponse(getEntity(id));
    }

    public SparePartResponse create(SparePartRequest request) {
        validate(request);

        BigDecimal price = request.getUnitPrice();

        SparePart part = SparePart.builder()
                .partName(request.getPartName().trim())
                .unit(request.getUnit().trim())
                .costPrice(price)
                .sellingPrice(price)
                .quantityInStock(request.getQuantityInStock() != null ? request.getQuantityInStock() : 0)
                .minStockLevel(request.getMinStockLevel() != null ? request.getMinStockLevel() : 0)
                .status(normalizeStatus(request.getStatus()))
                .build();

        return new SparePartResponse(sparePartRepository.save(part));
    }

    public SparePartResponse update(Integer id, SparePartRequest request) {
        validate(request);

        SparePart part = getEntity(id);
        part.setPartName(request.getPartName().trim());
        part.setUnit(request.getUnit().trim());
        part.setSellingPrice(request.getUnitPrice());
        // Không đụng cost_price trừ khi chưa có — tránh ghi đè dữ liệu nhóm
        if (part.getCostPrice() == null) {
            part.setCostPrice(request.getUnitPrice());
        }
        if (request.getQuantityInStock() != null) {
            part.setQuantityInStock(request.getQuantityInStock());
        }
        if (request.getMinStockLevel() != null) {
            part.setMinStockLevel(request.getMinStockLevel());
        }
        if (part.getStatus() == null || part.getStatus().isBlank()) {
            part.setStatus("ACTIVE");
        }
        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            part.setStatus(normalizeStatus(request.getStatus()));
        }

        return new SparePartResponse(sparePartRepository.save(part));
    }

    public SparePartResponse adjustStock(Integer id, StockAdjustRequest request) {
        if (request == null || request.getQuantityDelta() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "quantityDelta là bắt buộc");
        }

        SparePart part = getEntity(id);
        int next = part.getQuantityInStock() + request.getQuantityDelta();
        if (next < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Số lượng tồn không được âm");
        }
        part.setQuantityInStock(next);
        return new SparePartResponse(sparePartRepository.save(part));
    }

    private SparePart getEntity(Integer id) {
        return sparePartRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Không tìm thấy phụ tùng"
                ));
    }

    private void validate(SparePartRequest request) {
        if (request == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ");
        }
        if (request.getPartName() == null || request.getPartName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tên phụ tùng không được để trống");
        }
        if (request.getUnit() == null || request.getUnit().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Đơn vị không được để trống");
        }
        if (request.getUnitPrice() == null || request.getUnitPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Đơn giá phải lớn hơn 0");
        }
        if (request.getQuantityInStock() != null && request.getQuantityInStock() < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Số lượng tồn không hợp lệ");
        }
        if (request.getMinStockLevel() != null && request.getMinStockLevel() < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mức tồn tối thiểu không hợp lệ");
        }
    }

    private String normalizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return "ACTIVE";
        }
        return status.trim().toUpperCase();
    }
}
