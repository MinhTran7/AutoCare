package com.autocare.api.service;

import com.autocare.api.dto.garage.GarageDTO;
import com.autocare.api.entity.Garage;
import com.autocare.api.entity.GarageServiceLink;
import com.autocare.api.repository.GarageRepository;
import com.autocare.api.repository.GarageServiceLinkRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GarageQueryService {
    private final GarageRepository garageRepository;
    private final GarageServiceLinkRepository garageServiceLinkRepository;

    public List<GarageDTO> getGarages(List<Integer> serviceIds, Double userLat, Double userLng) {
        List<Garage> activeGarages = garageRepository.findByStatus(Garage.GarageStatus.ACTIVE);

        List<Garage> filtered;
        if (serviceIds == null || serviceIds.isEmpty()) {
            filtered = activeGarages;
        } else {
            List<GarageServiceLink> links = garageServiceLinkRepository.findByService_IdIn(serviceIds);
            Map<Integer, Set<Integer>> matchedByGarage = links.stream()
                    .collect(Collectors.groupingBy(
                            l -> l.getGarage().getId(),
                            Collectors.mapping(l -> l.getService().getId(), Collectors.toSet())));
            filtered = activeGarages.stream()
                    .filter(g -> matchedByGarage.getOrDefault(g.getId(), Set.of()).containsAll(serviceIds))
                    .toList();
        }

        List<GarageDTO> result = filtered.stream().map(g -> toDto(g, userLat, userLng)).collect(Collectors.toList());
        if (userLat != null && userLng != null) {
            result.sort(Comparator.comparing(GarageDTO::getDistanceKm, Comparator.nullsLast(Comparator.naturalOrder())));
        }
        return result;
    }

    private GarageDTO toDto(Garage g, Double userLat, Double userLng) {
        Double distanceKm = null;
        if (userLat != null && userLng != null && g.getLatitude() != null && g.getLongitude() != null) {
            distanceKm = haversineKm(userLat, userLng, g.getLatitude().doubleValue(), g.getLongitude().doubleValue());
        }
        return GarageDTO.builder()
                .id(g.getId()).name(g.getName()).address(g.getAddress())
                .latitude(g.getLatitude()).longitude(g.getLongitude())
                .distanceKm(distanceKm == null ? null : Math.round(distanceKm * 10) / 10.0)
                .build();
    }

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