package com.autocare.api.service;

import com.autocare.api.dto.garage.GarageDTO;
import com.autocare.api.entity.Garage;
import com.autocare.api.repository.GarageRepository;
import com.autocare.api.repository.GarageServiceLinkRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;


import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GarageQueryService {

    private final GarageRepository garageRepository;
    private final GarageServiceLinkRepository garageServiceLinkRepository;

    /**
     * Man hinh 3: "Chon Garage".
     * Neu serviceId != null -> chi tra ve cac garage co ho tro dich vu do.
     * Neu co lat/lng nguoi dung -> tinh khoang cach va sap xep gan -> xa (giong UI mockup 1.2km, 2.5km...).
     */
    public List<GarageDTO> getGarages(Integer serviceId, Double userLat, Double userLng) {
        List<Garage> garages = garageRepository.findByStatus(Garage.GarageStatus.ACTIVE);

        if (serviceId != null) {
            Set<Integer> garageIdsWithService = garageServiceLinkRepository.findByService_Id(serviceId)
                    .stream()
                    .map(link -> link.getGarage().getId())
                    .collect(Collectors.toSet());
            garages = garages.stream()
                    .filter(g -> garageIdsWithService.contains(g.getId()))
                    .toList();
        }

        List<GarageDTO> result = garages.stream()
                .map(g -> toDto(g, userLat, userLng))
                .collect(Collectors.toList());

        if (userLat != null && userLng != null) {
            result.sort(Comparator.comparing(
                    GarageDTO::getDistanceKm,
                    Comparator.nullsLast(Comparator.naturalOrder())));
        }
        return result;
    }

    private GarageDTO toDto(Garage g, Double userLat, Double userLng) {
        Double distanceKm = null;
        if (userLat != null && userLng != null && g.getLatitude() != null && g.getLongitude() != null) {
            distanceKm = haversineKm(userLat, userLng, g.getLatitude().doubleValue(), g.getLongitude().doubleValue());
        }
        return GarageDTO.builder()
                .id(g.getId())
                .name(g.getName())
                .address(g.getAddress())
                .latitude(g.getLatitude())
                .longitude(g.getLongitude())
                .distanceKm(distanceKm == null ? null : Math.round(distanceKm * 10) / 10.0)
                .build();
    }

    /** Cong thuc Haversine tinh khoang cach giua 2 toa do (km). */
    private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}

