class AdminMockData {
  static Map<String, dynamic> dashboardSummary() => {
        'totalBookingsInRange': 12,
        'bookingsByStatus': {
          'PENDING': 3,
          'CONFIRMED': 2,
          'IN_PROGRESS': 4,
          'COMPLETED': 2,
          'CANCELLED': 1,
        },
        'homeJobsInProgress': 2,
        'paidRevenue': 4500000,
        'totalCustomers': 8,
        'totalMechanics': 3,
        'lowStockCount': 2,
        'lowStockItems': [
          {
            'id': 1,
            'partName': 'Dầu nhớt 5W-30',
            'quantityInStock': 2,
            'minStockLevel': 5,
          },
          {
            'id': 2,
            'partName': 'Má phanh trước',
            'quantityInStock': 1,
            'minStockLevel': 4,
          },
        ],
      };

  static List<Map<String, dynamic>> customers() => [
        {
          'id': 1,
          'fullName': 'Nguyễn Văn A',
          'email': 'nguyenvana@gmail.com',
          'phone': '0901111222',
          'status': 'ACTIVE',
          'lockedReason': null,
          'createdAt': '2026-07-01T10:00:00',
        },
        {
          'id': 2,
          'fullName': 'Trần Thị B',
          'email': 'tranthib@gmail.com',
          'phone': '0903333444',
          'status': 'LOCKED',
          'lockedReason': 'Spam booking',
          'createdAt': '2026-07-02T11:00:00',
        },
      ];

  static List<Map<String, dynamic>> services() => [
        {
          'id': 1,
          'name': 'Thay nhớt',
          'description': 'Thay dầu động cơ',
          'price': 350000,
          'isHomeService': false,
          'status': 'ACTIVE',
        },
        {
          'id': 2,
          'name': 'Cứu hộ tận nơi',
          'description': 'Sửa chữa tại chỗ',
          'price': 500000,
          'isHomeService': true,
          'status': 'ACTIVE',
        },
      ];

  static List<Map<String, dynamic>> spareParts() => [
        {
          'id': 1,
          'partName': 'Dầu nhớt 5W-30',
          'unit': 'chai',
          'unitPrice': 180000,
          'quantityInStock': 2,
          'minStockLevel': 5,
          'status': 'ACTIVE',
          'lowStock': true,
        },
        {
          'id': 2,
          'partName': 'Lọc gió',
          'unit': 'cái',
          'unitPrice': 95000,
          'quantityInStock': 20,
          'minStockLevel': 5,
          'status': 'ACTIVE',
          'lowStock': false,
        },
      ];

  static List<Map<String, dynamic>> garages() => [
        {
          'id': 1,
          'name': 'AutoCare Quận 1',
          'address': '12 Nguyễn Huệ, Quận 1, TP.HCM',
          'phone': '02811112222',
          'status': 'ACTIVE',
        },
        {
          'id': 2,
          'name': 'AutoCare Thủ Đức',
          'address': '45 Võ Văn Ngân, Thủ Đức, TP.HCM',
          'phone': '02833334444',
          'status': 'ACTIVE',
        },
      ];
}
