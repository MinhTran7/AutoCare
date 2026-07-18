-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               9.6.0 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.17.0.7270
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for autocare_db
CREATE DATABASE IF NOT EXISTS `autocare_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `autocare_db`;

-- Dumping structure for table autocare_db.booking_slots
DROP TABLE IF EXISTS `booking_slots`;
CREATE TABLE IF NOT EXISTS `booking_slots` (
  `id` int NOT NULL AUTO_INCREMENT,
  `garage_id` int NOT NULL,
  `booking_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `status` enum('AVAILABLE','BOOKED','CANCELLED') NOT NULL DEFAULT 'AVAILABLE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_garage_slot` (`garage_id`,`booking_date`,`start_time`,`end_time`),
  CONSTRAINT `fk_booking_slot_garage` FOREIGN KEY (`garage_id`) REFERENCES `garages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.booking_slots: ~9 rows (approximately)
INSERT INTO `booking_slots` (`id`, `garage_id`, `booking_date`, `start_time`, `end_time`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, '2026-06-15', '08:00:00', '09:00:00', 'BOOKED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(2, 1, '2026-06-15', '09:00:00', '10:00:00', 'BOOKED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(3, 1, '2026-06-15', '10:00:00', '11:00:00', 'AVAILABLE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(4, 2, '2026-06-15', '08:00:00', '09:00:00', 'BOOKED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(5, 2, '2026-06-15', '09:00:00', '10:00:00', 'AVAILABLE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(6, 2, '2026-06-15', '10:00:00', '11:00:00', 'AVAILABLE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(7, 3, '2026-06-15', '13:00:00', '14:00:00', 'BOOKED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(8, 3, '2026-06-15', '14:00:00', '15:00:00', 'BOOKED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(9, 3, '2026-06-15', '15:00:00', '16:00:00', 'AVAILABLE', '2026-06-14 10:52:46', '2026-06-14 10:52:46');

-- Dumping structure for table autocare_db.bookings
DROP TABLE IF EXISTS `bookings`;
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vehicle_id` int NOT NULL,
  `garage_id` int NOT NULL,
  `service_id` int NOT NULL,
  `slot_id` int NOT NULL,
  `mechanic_id` int DEFAULT NULL,
  `booking_type` enum('GARAGE','HOME') NOT NULL,
  `service_address` text,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `status` enum('PENDING','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_booking_slot` (`slot_id`),
  KEY `fk_booking_mechanic` (`mechanic_id`),
  KEY `idx_booking_vehicle_id` (`vehicle_id`),
  KEY `idx_booking_garage_id` (`garage_id`),
  KEY `idx_booking_service_id` (`service_id`),
  KEY `idx_booking_status` (`status`),
  CONSTRAINT `fk_booking_garage` FOREIGN KEY (`garage_id`) REFERENCES `garages` (`id`),
  CONSTRAINT `fk_booking_mechanic` FOREIGN KEY (`mechanic_id`) REFERENCES `mechanics` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_booking_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`),
  CONSTRAINT `fk_booking_slot` FOREIGN KEY (`slot_id`) REFERENCES `booking_slots` (`id`),
  CONSTRAINT `fk_booking_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.bookings: ~5 rows (approximately)
INSERT INTO `bookings` (`id`, `vehicle_id`, `garage_id`, `service_id`, `slot_id`, `mechanic_id`, `booking_type`, `service_address`, `latitude`, `longitude`, `status`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, 1, 1, 1, 'GARAGE', NULL, NULL, NULL, 'CONFIRMED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(2, 2, 2, 4, 4, NULL, 'GARAGE', NULL, NULL, NULL, 'PENDING', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(3, 4, 3, 8, 8, 2, 'GARAGE', NULL, NULL, NULL, 'COMPLETED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(4, 3, 1, 2, 2, 1, 'HOME', '15 Nguyễn Chí Thanh, Hà Nội', 21.0278000, 105.8105000, 'CONFIRMED', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(5, 5, 3, 7, 7, 2, 'HOME', '50 Hoàng Quốc Việt, Hà Nội', 21.0462000, 105.7829000, 'IN_PROGRESS', '2026-06-14 10:52:46', '2026-06-14 10:52:46');

-- Dumping structure for table autocare_db.garage_services
DROP TABLE IF EXISTS `garage_services`;
CREATE TABLE IF NOT EXISTS `garage_services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `garage_id` int NOT NULL,
  `service_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_garage_service` (`garage_id`,`service_id`),
  KEY `fk_garage_service_service` (`service_id`),
  CONSTRAINT `fk_garage_service_garage` FOREIGN KEY (`garage_id`) REFERENCES `garages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_garage_service_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.garage_services: ~15 rows (approximately)
INSERT INTO `garage_services` (`id`, `garage_id`, `service_id`) VALUES
	(1, 1, 1),
	(2, 1, 2),
	(3, 1, 3),
	(4, 1, 4),
	(5, 1, 5),
	(6, 2, 1),
	(7, 2, 2),
	(8, 2, 4),
	(9, 2, 6),
	(10, 2, 8),
	(11, 3, 1),
	(12, 3, 3),
	(13, 3, 5),
	(14, 3, 7),
	(15, 3, 8);

-- Dumping structure for table autocare_db.garages
DROP TABLE IF EXISTS `garages`;
CREATE TABLE IF NOT EXISTS `garages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.garages: ~3 rows (approximately)
INSERT INTO `garages` (`id`, `name`, `address`, `latitude`, `longitude`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Garage Thành Công', '123 Trần Duy Hưng, Hà Nội', 21.0112000, 105.8035000, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(2, 'Garage Minh Phát', '45 Nguyễn Trãi, Hà Nội', 20.9954000, 105.8097000, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(3, 'Garage AutoCare', '88 Lê Văn Lương, Hà Nội', 21.0065000, 105.8018000, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46');

-- Dumping structure for table autocare_db.invoices
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE IF NOT EXISTS `invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `total_amount` decimal(15,2) NOT NULL,
  `payment_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `payment_method` varchar(50) DEFAULT NULL,
  `status` enum('UNPAID','PAID','CANCELLED') NOT NULL DEFAULT 'UNPAID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_id` (`booking_id`),
  CONSTRAINT `fk_invoice_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.invoices: ~2 rows (approximately)
INSERT INTO `invoices` (`id`, `booking_id`, `total_amount`, `payment_date`, `payment_method`, `status`, `created_at`, `updated_at`) VALUES
	(1, 3, 400000.00, '2026-06-14 10:52:46', 'CASH', 'PAID', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(2, 1, 250000.00, '2026-06-14 10:52:46', 'BANKING', 'PAID', '2026-06-14 10:52:46', '2026-06-14 10:52:46');

-- Dumping structure for table autocare_db.mechanics
DROP TABLE IF EXISTS `mechanics`;
CREATE TABLE IF NOT EXISTS `mechanics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `garage_id` int DEFAULT NULL,
  `specialty` varchar(100) DEFAULT NULL,
  `status` enum('AVAILABLE','BUSY','OFF') DEFAULT 'AVAILABLE',
  `rating` decimal(2,1) DEFAULT '5.0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `fk_mechanic_garage` (`garage_id`),
  CONSTRAINT `fk_mechanic_garage` FOREIGN KEY (`garage_id`) REFERENCES `garages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_mechanic_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.mechanics: ~2 rows (approximately)
INSERT INTO `mechanics` (`id`, `user_id`, `garage_id`, `specialty`, `status`, `rating`, `created_at`, `updated_at`) VALUES
	(1, 201, 1, 'Máy / Điện / Lốp', 'AVAILABLE', 5.0, '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(2, 202, 3, 'Phanh / Ắc quy / Bảo dưỡng', 'AVAILABLE', 4.8, '2026-06-14 10:52:46', '2026-06-14 10:52:46');

-- Dumping structure for table autocare_db.services
DROP TABLE IF EXISTS `services`;
CREATE TABLE IF NOT EXISTS `services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `is_home_service` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.services: ~8 rows (approximately)
INSERT INTO `services` (`id`, `name`, `price`, `is_home_service`, `status`, `created_at`, `updated_at`) VALUES
	(1, 'Thay dầu động cơ', 250000.00, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(2, 'Rửa xe', 80000.00, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(3, 'Thay lốp xe', 500000.00, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(4, 'Kiểm tra động cơ', 300000.00, 0, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(5, 'Sửa phanh', 450000.00, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(6, 'Cân chỉnh bánh xe', 350000.00, 0, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(7, 'Thay ắc quy', 1200000.00, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(8, 'Vệ sinh kim phun', 400000.00, 0, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46');

-- Dumping structure for table autocare_db.spare_parts
DROP TABLE IF EXISTS `spare_parts`;
CREATE TABLE IF NOT EXISTS `spare_parts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `part_name` varchar(200) NOT NULL,
  `unit` varchar(50) NOT NULL,
  `cost_price` decimal(15,2) NOT NULL,
  `selling_price` decimal(15,2) NOT NULL,
  `quantity_in_stock` int NOT NULL DEFAULT '0',
  `min_stock_level` int NOT NULL DEFAULT '5',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.spare_parts: ~6 rows (approximately)
INSERT INTO `spare_parts` (`id`, `part_name`, `unit`, `cost_price`, `selling_price`, `quantity_in_stock`, `min_stock_level`, `created_at`, `updated_at`) VALUES
	(1, 'Dầu động cơ Castrol', 'Lít', 120000.00, 180000.00, 50, 10, '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(2, 'Lốp Michelin 15 inch', 'Cái', 900000.00, 1200000.00, 20, 5, '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(3, 'Ắc quy GS 12V', 'Cái', 850000.00, 1200000.00, 15, 3, '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(4, 'Má phanh trước', 'Bộ', 300000.00, 450000.00, 25, 5, '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(5, 'Lọc gió động cơ', 'Cái', 100000.00, 180000.00, 30, 5, '2026-06-14 10:52:46', '2026-06-14 10:52:46'),
	(6, 'Bugi Bosch', 'Cái', 80000.00, 150000.00, 40, 8, '2026-06-14 10:52:46', '2026-06-14 10:52:46');

-- Dumping structure for table autocare_db.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'CUSTOMER',
  `address` varchar(255) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `status` enum('ACTIVE','LOCKED','DELETED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=203 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.users: ~8 rows (approximately)
INSERT INTO `users` (`id`, `full_name`, `email`, `phone`, `password`, `role`, `address`, `avatar_url`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 'Admin AutoCare', 'nguyenhaiphong518@gmail.com', '0900000001', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'ADMIN', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(101, 'Nguyễn Văn A', 'customer101@gmail.com', '0910000101', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'CUSTOMER', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(102, 'Trần Văn B', 'customer102@gmail.com', '0910000102', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'CUSTOMER', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(103, 'Lê Văn C', 'customer103@gmail.com', '0910000103', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'CUSTOMER', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(104, 'Phạm Văn D', 'customer104@gmail.com', '0910000104', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'CUSTOMER', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(105, 'Hoàng Văn E', 'customer105@gmail.com', '0910000105', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'CUSTOMER', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(201, 'Nguyễn Minh Thợ', 'mechanic1@gmail.com', '0900000201', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'MECHANIC', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(202, 'Trần Văn Thợ', 'mechanic2@gmail.com', '0900000202', '$2a$10$Tg6u0oL5Nhc3wCh3I4n2TOCheiEmq99Y1EZOtAmSxcCPwS3eeqa6i', 'MECHANIC', 'Hà Nội', NULL, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL);

-- Dumping structure for table autocare_db.vehicles
DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vehicle_type` varchar(50) NOT NULL DEFAULT 'CAR',
  `brand` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  `license_plate` varchar(30) NOT NULL,
  `manufacturing_year` int DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `mileage` int NOT NULL DEFAULT '0',
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('ACTIVE','DELETED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_license_plate` (`license_plate`),
  KEY `idx_vehicle_user_id` (`user_id`),
  CONSTRAINT `fk_vehicle_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table autocare_db.vehicles: ~5 rows (approximately)
INSERT INTO `vehicles` (`id`, `user_id`, `vehicle_type`, `brand`, `model`, `license_plate`, `manufacturing_year`, `color`, `mileage`, `is_default`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 101, 'CAR', 'Toyota', 'Vios', '30A-12345', 2020, 'Trắng', 25000, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(2, 102, 'CAR', 'Honda', 'City', '29B-56789', 2021, 'Đen', 18000, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(3, 103, 'CAR', 'Hyundai', 'Accent', '30G-88888', 2019, 'Đỏ', 35000, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(4, 104, 'CAR', 'Mazda', 'Mazda3', '30H-99999', 2022, 'Xám', 12000, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL),
	(5, 105, 'CAR', 'Kia', 'Seltos', '30K-11111', 2023, 'Trắng', 8000, 1, 'ACTIVE', '2026-06-14 10:52:46', '2026-06-14 10:52:46', NULL);

CREATE TABLE IF NOT EXISTS `booking_spare_parts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `spare_part_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `price` decimal(15,2) NOT NULL, -- Lưu giá tại thời điểm thay thế
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_bsp_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bsp_part` FOREIGN KEY (`spare_part_id`) REFERENCES `spare_parts` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `mechanic_attendances` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mechanic_id` int NOT NULL,
  `work_date` date NOT NULL,
  `check_in_time` time DEFAULT NULL,
  `check_out_time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_mechanic_date` (`mechanic_id`, `work_date`),
  CONSTRAINT `fk_attendance_mechanic` FOREIGN KEY (`mechanic_id`) REFERENCES `mechanics` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
