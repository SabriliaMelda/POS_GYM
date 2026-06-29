-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 29, 2026 at 04:55 PM
-- Server version: 8.4.3
-- PHP Version: 8.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pos_gym`
--

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `id` bigint UNSIGNED NOT NULL,
  `member_code` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  `member_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `attendance_date` date NOT NULL,
  `check_in_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `method` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'barcode',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `food_beverage_items`
--

CREATE TABLE `food_beverage_items` (
  `id` bigint UNSIGNED NOT NULL,
  `item_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `member_price` decimal(12,2) UNSIGNED NOT NULL,
  `price` decimal(12,2) UNSIGNED NOT NULL COMMENT 'Harga non-member',
  `stock` int UNSIGNED NOT NULL DEFAULT '0',
  `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `food_beverage_items`
--

INSERT INTO `food_beverage_items` (`id`, `item_id`, `name`, `description`, `category`, `member_price`, `price`, `stock`, `image_path`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'FNB-001', 'Chicken Salad', 'Menu salad Rumah Hobi', 'Makanan', 35000.00, 35000.00, 43, '/uploads/fnb/c644730f2a900d45a7b3b291743139b2.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(2, 'FNB-002', 'Chicken Grill Salad & Fries', 'Menu salad Rumah Hobi', 'Makanan', 30000.00, 30000.00, 92, '/uploads/fnb/331a406f3b393fb312b5f15615d330b2.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(3, 'FNB-003', 'Mix Salad Protein', 'Menu salad Rumah Hobi', 'Makanan', 45000.00, 45000.00, 2, '/uploads/fnb/bc3bf2607fb4f832b4989ba0b26318b4.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(4, 'FNB-004', 'Mix Vegetable Chicken Salad', 'Menu salad Rumah Hobi', 'Makanan', 25000.00, 25000.00, 4, '/uploads/fnb/caedfa24b52b75e74b52a21072a1fcdc.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(5, 'FNB-005', 'Salmon Salad', 'Menu salad Rumah Hobi', 'Makanan', 45000.00, 45000.00, 1, '/uploads/fnb/1839c6c0d04fa7ee4474442a329284a6.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(6, 'FNB-006', 'Healthy Food Salad', 'Menu salad Rumah Hobi', 'Makanan', 45000.00, 45000.00, 23, '/uploads/fnb/da44f4ba5abe4dec2552fd30bcb5c46e.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(7, 'FNB-007', 'Nasi Sapi Hitam', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 54, '/uploads/fnb/35a70156485a76ccb8a43b59e5eca136.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(8, 'FNB-008', 'Nasi Cabe Hijau', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 0, '/uploads/fnb/cat-rice.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(9, 'FNB-009', 'Nasi Capcay', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 50, '/uploads/fnb/cat-rice.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(10, 'FNB-010', 'Nasi Kung Pao Chicken', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 82, '/uploads/fnb/ec03e483ea50dc599814993697d3aed7.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(11, 'FNB-011', 'Honey Chicken Rice', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 3, '/uploads/fnb/5e093300ec3dce8ec2fcfb46673e7d62.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(12, 'FNB-012', 'Nasi Sapi/Ayam Saus Tausi', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 16, '/uploads/fnb/4db0a76de50d3f941b3234c27d50fbe5.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(13, 'FNB-013', 'Szechuan Chicken', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 25, '/uploads/fnb/061bc56cc83b0181d1a1e5cd5f906522.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(14, 'FNB-014', 'Nasi Ayam Saus Asam Manis', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 5, '/uploads/fnb/af5ffd7954f030dbd240161241edcc0f.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(15, 'FNB-015', 'Nasi Ayam Serundeng', 'Menu nasi Rumah Hobi', 'Makanan', 30000.00, 30000.00, 84, '/uploads/fnb/cat-rice.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(16, 'FNB-016', 'Spaghetti Bolognese', 'Menu spaghetti Rumah Hobi', 'Makanan', 30000.00, 30000.00, 15, '/uploads/fnb/05520e0d437661eece0aa7ce9ee3506b.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(17, 'FNB-017', 'Spaghetti Carbonara', 'Menu spaghetti Rumah Hobi', 'Makanan', 30000.00, 30000.00, 0, '/uploads/fnb/94e2153d43073da5bfe05719a5a2fa8d.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(18, 'FNB-018', 'Spaghetti Aglio Olio Healthy Food', 'Menu spaghetti Rumah Hobi', 'Makanan', 40000.00, 40000.00, 82, '/uploads/fnb/7af5aac31cc990a9e51cf2b47ac102b0.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(19, 'FNB-019', 'Indomie Rebus/Goreng Tanpa Telur', 'Menu Indomie Rumah Hobi', 'Makanan', 10000.00, 10000.00, 46, '/uploads/fnb/db8f893b0a7ad3ac9cd12fc3082b37ac.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(20, 'FNB-020', 'Paket Mie Rebus/Goreng Pakai Telur', 'Menu Indomie Rumah Hobi', 'Makanan', 15000.00, 15000.00, 35, '/uploads/fnb/1c51ce5f66ab010a22ad70702be188d9.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(21, 'FNB-021', 'Cireng RH', 'Menu appetizer Rumah Hobi', 'Appetizer', 18000.00, 20000.00, 81, '/uploads/fnb/5b5e3027b8ae844216cd8d7945e9239b.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(22, 'FNB-022', 'French Fries', 'Menu appetizer Rumah Hobi', 'Appetizer', 18000.00, 20000.00, 5, '/uploads/fnb/bb8a51bad9822bd22f22804e47527695.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(23, 'FNB-023', 'Dimsum', 'Menu appetizer Rumah Hobi', 'Appetizer', 18000.00, 20000.00, 2, '/uploads/fnb/7fc32c2e11b0fd7f3be89218b65f3b08.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(24, 'FNB-024', 'Pisang Goreng Wijen', 'Menu appetizer Rumah Hobi', 'Appetizer', 18000.00, 20000.00, 66, '/uploads/fnb/d743d4b93aba726d8cc51b59a7047bcf.jpg', 1, '2026-06-21 10:42:07', '2026-06-27 19:24:17'),
(25, 'FNB-025', 'Thai Fried Chicken', 'Menu appetizer Rumah Hobi', 'Appetizer', 20000.00, 28000.00, 29, '/uploads/fnb/fe264a44b4c424796ac88e94f7b7db64.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(26, 'FNB-026', 'Chicken Wings', 'Menu appetizer Rumah Hobi', 'Appetizer', 20000.00, 25000.00, 19, '/uploads/fnb/aaa06f77bbee1d499410b8c65b5a6e57.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(27, 'FNB-027', 'Roti Bakar Manis', 'Menu appetizer Rumah Hobi', 'Appetizer', 10000.00, 15000.00, 4, '/uploads/fnb/e4714a200ed4d78472aa3459c065b10b.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(28, 'FNB-028', 'Lumpia RH', 'Menu appetizer Rumah Hobi', 'Appetizer', 22000.00, 25000.00, 57, '/uploads/fnb/8cfcf2214a9ab7131f5badd5a8dec135.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(29, 'FNB-029', 'Otak-Otak Goreng', 'Menu appetizer Rumah Hobi', 'Appetizer', 18000.00, 20000.00, 37, '/uploads/fnb/d1cd11e635753c9d333e4ddab47de2fd.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(30, 'FNB-030', 'Bakwan Jagung', 'Menu appetizer Rumah Hobi', 'Appetizer', 18000.00, 18000.00, 94, '/uploads/fnb/0892ab654426b92984f20f3a34dc0c0d.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(31, 'FNB-031', 'Americano', 'Menu coffee Rumah Hobi', 'Minuman', 15000.00, 25000.00, 0, '/uploads/fnb/d7427915240f987d414bb7ca34325018.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(32, 'FNB-032', 'Cappuccino', 'Menu coffee Rumah Hobi', 'Minuman', 18000.00, 28000.00, 5, '/uploads/fnb/01362e2951f603a0de20e7f1f64ddc0f.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(33, 'FNB-033', 'Cafe Latte', 'Menu coffee Rumah Hobi', 'Minuman', 18000.00, 28000.00, 5, '/uploads/fnb/3c668e944d6682ee72ed08cc9faeadfd.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(34, 'FNB-034', 'Vanilla Aren', 'Menu coffee Rumah Hobi', 'Minuman', 20000.00, 28000.00, 0, '/uploads/fnb/29e58b1ac9b10315b81aac9cee7834c8.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(35, 'FNB-035', 'Banana Espresso', 'Menu coffee Rumah Hobi', 'Minuman', 28000.00, 35000.00, 50, '/uploads/fnb/149bf6210e846f37238ca160f3f9c312.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(36, 'FNB-036', 'Matcha Latte', 'Menu coffee Rumah Hobi', 'Minuman', 18000.00, 28000.00, 2, '/uploads/fnb/012acfb33660f8f903efaa4174f26560.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(37, 'FNB-037', 'Avocado Latte Espresso', 'Menu coffee Rumah Hobi', 'Minuman', 28000.00, 35000.00, 4, '/uploads/fnb/d3687060a371f43aa569237577b5adbd.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(38, 'FNB-038', 'Coklat Latte', 'Menu coffee Rumah Hobi', 'Minuman', 18000.00, 28000.00, 74, '/uploads/fnb/f454a013f285e0e01064481abf3887bc.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(39, 'FNB-039', 'Vanilla Latte Ice', 'Menu coffee Rumah Hobi', 'Minuman', 15000.00, 25000.00, 4, '/uploads/fnb/eee4c6e0dc53509b2728fac7771f986a.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(40, 'FNB-040', 'Pandan Coffee Latte', 'Menu coffee Rumah Hobi', 'Minuman', 22000.00, 30000.00, 82, '/uploads/fnb/ecfa7505621436ab4f271318f6964348.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(41, 'FNB-041', 'Hazelnut Coffee Latte', 'Menu coffee Rumah Hobi', 'Minuman', 18000.00, 28000.00, 0, '/uploads/fnb/529cddfeb5e2724856dcd9cbd777b626.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(42, 'FNB-042', 'Marie Regal Shake', 'Menu minuman Rumah Hobi', 'Minuman', 25000.00, 35000.00, 5, '/uploads/fnb/af8680844eff49710b2b0a06ab89261f.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(43, 'FNB-043', 'Oreo Cookies Cream', 'Menu minuman Rumah Hobi', 'Minuman', 25000.00, 35000.00, 16, '/uploads/fnb/158e74f79859df93b1bd774918685c32.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(44, 'FNB-044', 'Green Tea', 'Menu minuman Rumah Hobi', 'Minuman', 20000.00, 28000.00, 4, '/uploads/fnb/06d61b30dff12950b5432f0f5eecd0b6.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(45, 'FNB-045', 'Lemon Tea', 'Menu minuman Rumah Hobi', 'Minuman', 20000.00, 25000.00, 1, '/uploads/fnb/05f36b3128013377d00162e34d706297.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(46, 'FNB-046', 'Lychee Tea', 'Menu minuman Rumah Hobi', 'Minuman', 20000.00, 28000.00, 1, '/uploads/fnb/238aee427cbf8f8ae3ec38511254867a.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(47, 'FNB-047', 'Milky Brown Sugar', 'Menu minuman Rumah Hobi', 'Minuman', 25000.00, 30000.00, 0, '/uploads/fnb/da7571aa48e2815c07f2ab8b24791b6a.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(48, 'FNB-048', 'Salted Caramel Macchiato', 'Menu minuman Rumah Hobi', 'Minuman', 28000.00, 35000.00, 12, '/uploads/fnb/ec017cf6e19603a33bd11fc5d6b60a1d.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(49, 'FNB-049', 'Red Velvet', 'Menu minuman Rumah Hobi', 'Minuman', 25000.00, 35000.00, 71, '/uploads/fnb/0dd83143b7f15c13a8bbcb9d272db305.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(50, 'FNB-050', 'Mix Juice', 'Menu minuman Rumah Hobi', 'Minuman', 18000.00, 25000.00, 98, '/uploads/fnb/8e28e038449e2603375bf1db69df73fc.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 17:33:32'),
(51, 'FNB-051', 'Ice Tea', 'Menu minuman Rumah Hobi', 'Minuman', 10000.00, 15000.00, 0, '/uploads/fnb/bedf713bb50024af9760ddb17be49897.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(52, 'FNB-052', 'Mineral Water', 'Menu minuman Rumah Hobi', 'Minuman', 5000.00, 10000.00, 0, '/uploads/fnb/435a290530f8eb148e8d1cfcc5b9a1cd.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(53, 'FNB-053', 'Nasi Goreng Ala Rumah Hobi', 'Menu nasi goreng Rumah Hobi', 'Makanan', 20000.00, 25000.00, 43, '/uploads/fnb/3610735e1f02a775a35eed4870b6ccb8.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(54, 'FNB-054', 'Nasi Goreng Kecap', 'Menu nasi goreng Rumah Hobi', 'Makanan', 20000.00, 25000.00, 0, '/uploads/fnb/3470fdbefb527199adc994f5a34402fc.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(55, 'FNB-055', 'Nasi Goreng Ikan Asin', 'Menu nasi goreng Rumah Hobi', 'Makanan', 25000.00, 30000.00, 0, '/uploads/fnb/bf3de0ad49fdecffdee0f4d5806cb027.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(56, 'FNB-056', 'Nasi Goreng Vegetarian', 'Menu nasi goreng Rumah Hobi', 'Makanan', 25000.00, 30000.00, 4, '/uploads/fnb/8c139ca099a01b676d51a6eb36f96918.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(57, 'FNB-057', 'Nasi Goreng Oriental', 'Menu nasi goreng Rumah Hobi', 'Makanan', 28000.00, 35000.00, 46, '/uploads/fnb/feeb46a730a383789eafb339a9ffb2ba.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(58, 'FNB-058', 'Nasi Goreng Kampung', 'Menu nasi goreng Rumah Hobi', 'Makanan', 28000.00, 35000.00, 26, '/uploads/fnb/dad4c4508a25212c9a54ad578b9eac69.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(59, 'FNB-059', 'Nasi Goreng Singapore', 'Menu nasi goreng Rumah Hobi', 'Makanan', 28000.00, 35000.00, 1, '/uploads/fnb/cf9d1c3faa3ab0836125ba367d3ef2bd.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(60, 'FNB-060', 'Nasi Goreng Hongkong', 'Menu nasi goreng Rumah Hobi', 'Makanan', 28000.00, 35000.00, 2, '/uploads/fnb/cfca1d15b07db2f0ed1d60f371346b14.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(61, 'FNB-061', 'Nasi Goreng Seafood', 'Menu nasi goreng Rumah Hobi', 'Makanan', 28000.00, 35000.00, 80, '/uploads/fnb/6de83c2754ea6ed215477d2193c096d9.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(62, 'FNB-062', 'Nasi Goreng Kebuli', 'Menu nasi goreng Rumah Hobi', 'Makanan', 30000.00, 36000.00, 1, '/uploads/fnb/de41281e6a64f2cc3a0e3447403aa4d8.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(63, 'FNB-063', 'Nasi Goreng Cabe Ijo Beef', 'Menu nasi goreng Rumah Hobi', 'Makanan', 30000.00, 36000.00, 81, '/uploads/fnb/1ac1622c430f95270c99462157062b1c.jpg', 1, '2026-06-21 10:42:07', '2026-06-27 19:24:17'),
(64, 'FNB-064', 'Kwetiau Goreng Kecap', 'Menu kwetiau Rumah Hobi', 'Makanan', 25000.00, 30000.00, 0, '/uploads/fnb/fbd3e6e8a02c4595d0309156e921800b.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(65, 'FNB-065', 'Kwetiau Siram', 'Menu kwetiau Rumah Hobi', 'Makanan', 28000.00, 35000.00, 5, '/uploads/fnb/5700da3897d0e333c6b172d833321295.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(66, 'FNB-066', 'Kwetiau Goreng Kampung', 'Menu kwetiau Rumah Hobi', 'Makanan', 28000.00, 35000.00, 4, '/uploads/fnb/984030041f732f4554aef26c1c0bd1cc.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(67, 'FNB-067', 'Kwetiau Goreng Thailand', 'Menu kwetiau Rumah Hobi', 'Makanan', 28000.00, 35000.00, 52, '/uploads/fnb/afa779fabd727eb380c6cdf066e0428f.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(68, 'FNB-068', 'Kwetiau Goreng Singapore', 'Menu kwetiau Rumah Hobi', 'Makanan', 28000.00, 35000.00, 3, '/uploads/fnb/3a47bfa057a1217a5bc5159fea104efe.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(69, 'FNB-069', 'Garlic Kailan', 'Menu sayuran Rumah Hobi', 'Makanan', 20000.00, 20000.00, 33, '/uploads/fnb/3291777197a6d1d8d0d4d4fdcbed8eea.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(70, 'FNB-070', 'Garlic Broccoli', 'Menu sayuran Rumah Hobi', 'Makanan', 20000.00, 20000.00, 71, '/uploads/fnb/684c2d5b0dfefd8f9adbcc40e3944ae1.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(71, 'FNB-071', 'Garlic Baby Kalian', 'Menu sayuran Rumah Hobi', 'Makanan', 20000.00, 20000.00, 11, '/uploads/fnb/5e5c1ba0ef6619ba4a79af2cadf61d1e.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(72, 'FNB-072', 'Kailan With Oyster Sauce', 'Menu sayuran Rumah Hobi', 'Makanan', 23000.00, 23000.00, 83, '/uploads/fnb/b86dacb9877ccde289f9e451ec1d4f8c.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(73, 'FNB-073', 'Kangkung Balacan', 'Menu sayuran Rumah Hobi', 'Makanan', 18000.00, 18000.00, 0, '/uploads/fnb/a802972c2eaecafd03bfe693a5c67bdf.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(74, 'FNB-074', 'Toge Cah Ikan Asin', 'Menu sayuran Rumah Hobi', 'Makanan', 18000.00, 18000.00, 95, '/uploads/fnb/67c671401144091d7e78c76e10b33d99.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(75, 'FNB-075', 'Buncis Cah Ayam/Ikan Asin', 'Menu sayuran Rumah Hobi', 'Makanan', 20000.00, 20000.00, 69, '/uploads/fnb/3da025071917a30913884f6a3818da5b.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(76, 'FNB-076', 'Mie Goreng Kampung', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 41, '/uploads/fnb/23b77ff87643e493ab92ad0fad9c580f.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(77, 'FNB-077', 'Mie Goreng Malaysia', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 3, '/uploads/fnb/6718a890be5950bad456d0bca99af53a.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(78, 'FNB-078', 'Mie Goreng Singapore', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 2, '/uploads/fnb/706ab67b1119363e42e80674a00cf0b0.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(79, 'FNB-079', 'Mie Goreng Cabe Garam', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 11, '/uploads/fnb/fec6d6f6eab8882e3badde6ec76ce109.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(80, 'FNB-080', 'Mie Goreng Hongkong', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 95, '/uploads/fnb/ee81496d4ed3c2e361e23108896c620a.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(81, 'FNB-081', 'Mie Kuah Godog', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 0, '/uploads/fnb/7f98a7c16bbfe275f129b5d4b46cc7bb.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(82, 'FNB-082', 'Mie Ayam', 'Menu mie Rumah Hobi', 'Makanan', 25000.00, 30000.00, 4, '/uploads/fnb/deb034ae59bf7a69faf86c4cdfebdb0b.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(83, 'FNB-083', 'Mie Ayam Spesial', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 0, '/uploads/fnb/8d00d1bd12d3f1647ea3ee959987d5aa.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(84, 'FNB-084', 'Mie Ayam Wonton', 'Menu mie Rumah Hobi', 'Makanan', 28000.00, 35000.00, 0, '/uploads/fnb/ce4548dc376cf18948712b9781632df8.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(85, 'FNB-085', 'Bihun Kuah Godog', 'Menu bihun Rumah Hobi', 'Makanan', 18000.00, 25000.00, 86, '/uploads/fnb/f8435432f125f24f423dca27e4daca6a.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(86, 'FNB-086', 'Bihun Goreng', 'Menu bihun Rumah Hobi', 'Makanan', 20000.00, 25000.00, 1, '/uploads/fnb/eebd0340e658293dab34b938dc2ed5bd.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(87, 'FNB-087', 'Rice Bowl Sambal Geprek', 'Menu rice bowl Rumah Hobi', 'Makanan', 25000.00, 36000.00, 0, '/uploads/fnb/9e4c03b8c6da4f8f96926e20d4f07b5d.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(88, 'FNB-088', 'Rice Bowl Cabe Garam', 'Menu rice bowl Rumah Hobi', 'Makanan', 26000.00, 35000.00, 58, '/uploads/fnb/f42fca008f3272bbb59bdfbfcc0ce682.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(89, 'FNB-089', 'Rice Bowl Asam Manis', 'Menu rice bowl Rumah Hobi', 'Makanan', 26000.00, 35000.00, 63, '/uploads/fnb/9caeca26bc4e2ba84e470817cf57b9a7.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(90, 'FNB-090', 'Rice Bowl Sambel Matah', 'Menu rice bowl Rumah Hobi', 'Makanan', 25000.00, 34000.00, 0, '/uploads/fnb/ad74e78a6cb66226d39f658df6fbaacf.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(91, 'FNB-091', 'Rice Bowl Cabe Hijau', 'Menu rice bowl Rumah Hobi', 'Makanan', 28000.00, 34000.00, 14, '/uploads/fnb/d3c80e852c8c462ddbbff154ef58cfa5.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(92, 'FNB-092', 'Rice Bowl Lada Hitam', 'Menu rice bowl Rumah Hobi', 'Makanan', 25000.00, 25000.00, 66, '/uploads/fnb/65394f2aec6b7a869a8fdf19aeac5c50.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(93, 'FNB-093', 'Rice Bowl Telur Asin', 'Menu rice bowl Rumah Hobi', 'Makanan', 30000.00, 36000.00, 29, '/uploads/fnb/f9bb0f57cd3f8168e87929d31dff8c14.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(94, 'FNB-094', 'Rice Bowl Beef Teriyaki', 'Menu rice bowl Rumah Hobi', 'Makanan', 25000.00, 35000.00, 95, '/uploads/fnb/069b7d19faa95d377e940b8d1e0070fa.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(95, 'FNB-095', 'Rice Bowl Ayam Serundeng', 'Menu rice bowl Rumah Hobi', 'Makanan', 30000.00, 36000.00, 48, '/uploads/fnb/5b0823a3abd26438390cc7368e298fc0.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(96, 'FNB-096', 'Sapo Tofu', 'Menu tofu Rumah Hobi', 'Makanan', 30000.00, 30000.00, 75, '/uploads/fnb/f47bb8b07f0526a15e46564e16f5bd20.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(97, 'FNB-097', 'Moon Tofu', 'Menu tofu Rumah Hobi', 'Makanan', 28000.00, 28000.00, 0, '/uploads/fnb/fbbf1af69d5409bcf61ff104b389fbe8.jpg', 1, '2026-06-21 10:42:07', '2026-06-21 14:58:03'),
(98, 'FNB-098', 'Tofu Cabe Garam', 'Menu tofu Rumah Hobi', 'Makanan', 28000.00, 28000.00, 69, '/uploads/fnb/d6765fb1e8776f551fb7bc427cc9d7c6.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(99, 'FNB-099', 'Chief Tofu', 'Menu tofu Rumah Hobi', 'Makanan', 25000.00, 25000.00, 32, '/uploads/fnb/4064677e535b529c95db785b97aa691e.jpg', 1, '2026-06-21 10:42:07', '2026-06-25 16:59:25'),
(102, 'FNB-100', 'Nasi', 'Menu tambahan', 'Additional', 5000.00, 5000.00, 79, '/uploads/fnb/8fe26f77d3c041335a22947d996e3476.jpg', 1, '2026-06-21 15:05:06', '2026-06-27 18:19:17'),
(103, 'FNB-101', 'Telur', 'Menu tambahan', 'Additional', 5000.00, 5000.00, 25, '/uploads/fnb/b699bab27330db1a53b04d3329cbde33.jpg', 1, '2026-06-21 15:05:06', '2026-06-25 16:59:25'),
(104, 'FNB-102', 'Sosis', 'Menu tambahan', 'Additional', 8000.00, 8000.00, 85, '/uploads/fnb/531433e7a6358e1f054c1df17271cf1a.jpg', 1, '2026-06-21 15:05:06', '2026-06-25 16:59:25'),
(105, 'FNB-103', 'Kornet', 'Menu tambahan', 'Additional', 10000.00, 10000.00, 52, '/uploads/fnb/c40ad741af4fb59f8820f22491918cc1.jpg', 1, '2026-06-21 15:05:06', '2026-06-27 10:58:33'),
(106, 'FNB-104', 'Nugget', 'Menu tambahan', 'Additional', 10000.00, 10000.00, 0, '/uploads/fnb/f4d1cdb85a84aab314db5ce392e3b8e1.jpg', 1, '2026-06-21 15:05:06', '2026-06-21 15:11:11');

-- --------------------------------------------------------

--
-- Table structure for table `food_beverage_transactions`
--

CREATE TABLE `food_beverage_transactions` (
  `id` bigint UNSIGNED NOT NULL,
  `transaction_code` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `member_code` varchar(12) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `items` json NOT NULL,
  `total_amount` decimal(12,2) UNSIGNED NOT NULL,
  `discount_amount` decimal(12,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(12,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `final_amount` decimal(12,2) UNSIGNED NOT NULL,
  `payment_method` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'completed',
  `notes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `food_beverage_transactions`
--

INSERT INTO `food_beverage_transactions` (`id`, `transaction_code`, `member_code`, `customer_name`, `items`, `total_amount`, `discount_amount`, `tax_amount`, `final_amount`, `payment_method`, `status`, `notes`, `transaction_date`, `created_at`) VALUES
(3, 'FNB-4A20D760F3', 'MBR-58310427', 'Sabrilia Melda', '[{\"name\": \"Nasi\", \"price\": 5000, \"item_id\": 102, \"quantity\": 1, \"subtotal\": 5000}, {\"name\": \"Kornet\", \"price\": 9000, \"item_id\": 105, \"quantity\": 1, \"subtotal\": 9000}]', 14000.00, 0.00, 0.00, 14000.00, 'QRIS', 'completed', 'Pembeli member: Sabrilia Melda', '2026-06-25 17:36:38', '2026-06-25 17:36:38'),
(4, 'FNB-FDD539B6E0', NULL, 'Non-member', '[{\"name\": \"Kornet\", \"price\": 10000, \"item_id\": 105, \"quantity\": 1, \"subtotal\": 10000}, {\"name\": \"Nasi\", \"price\": 5000, \"item_id\": 102, \"quantity\": 1, \"subtotal\": 5000}]', 15000.00, 0.00, 0.00, 15000.00, 'QRIS', 'completed', 'Pembeli non-member', '2026-06-27 10:54:37', '2026-06-27 10:54:37'),
(5, 'FNB-B19DDFEFD3', NULL, 'Non-member', '[{\"name\": \"Nasi\", \"price\": 5000, \"item_id\": 102, \"quantity\": 2, \"subtotal\": 10000}]', 10000.00, 0.00, 0.00, 10000.00, 'QRIS', 'completed', 'Pembeli non-member', '2026-06-27 10:55:30', '2026-06-27 10:55:30'),
(6, 'FNB-4B18A8DD75', NULL, 'Non-member', '[{\"name\": \"Kornet\", \"price\": 10000, \"item_id\": 105, \"quantity\": 1, \"subtotal\": 10000}]', 10000.00, 0.00, 0.00, 10000.00, 'QRIS', 'completed', 'Pembeli non-member', '2026-06-27 10:58:33', '2026-06-27 10:58:33'),
(7, 'FNB-C54E359E21', NULL, 'Non-member', '[{\"name\": \"Nasi\", \"price\": 5000, \"item_id\": 102, \"quantity\": 1, \"subtotal\": 5000}]', 5000.00, 0.00, 0.00, 5000.00, 'QRIS', 'completed', 'Pembeli non-member', '2026-06-27 11:02:21', '2026-06-27 11:02:21'),
(8, 'FNB-D6081C14F7', NULL, 'Non-member', '[{\"name\": \"Nasi\", \"price\": 5000, \"item_id\": 102, \"quantity\": 1, \"subtotal\": 5000}]', 5000.00, 0.00, 0.00, 5000.00, 'QRIS', 'completed', 'Pembeli non-member', '2026-06-27 11:29:52', '2026-06-27 11:29:52'),
(9, 'FNB-81F0052CFD', NULL, 'Non-member', '[{\"name\": \"Nasi\", \"price\": 5000, \"item_id\": 102, \"quantity\": 1, \"subtotal\": 5000}]', 5000.00, 0.00, 0.00, 5000.00, 'QRIS', 'completed', 'Pembeli non-member', '2026-06-27 18:18:22', '2026-06-27 18:18:22'),
(10, 'FNB-3FE10EB300', NULL, 'Non-member', '[{\"name\": \"Nasi\", \"price\": 5000, \"item_id\": 102, \"quantity\": 1, \"subtotal\": 5000}]', 5000.00, 0.00, 0.00, 5000.00, 'QRIS', 'completed', 'Pembeli non-member', '2026-06-27 18:19:17', '2026-06-27 18:19:17'),
(11, 'FNB-755808F2B6', 'MBR-80788719', 'Galih Kartika', '[{\"name\": \"Nasi Goreng Cabe Ijo Beef\", \"price\": 32000, \"item_id\": 63, \"quantity\": 1, \"subtotal\": 32000}, {\"name\": \"Pisang Goreng Wijen\", \"price\": 18000, \"item_id\": 24, \"quantity\": 1, \"subtotal\": 18000}]', 50000.00, 0.00, 0.00, 50000.00, 'QRIS', 'completed', 'Pembeli member: Galih Kartika', '2026-06-27 19:24:17', '2026-06-27 19:24:17'),
(12, 'FNB-S000001', 'MBR-58310427', 'Sabrilia Melda', '[{\"name\": \"Chicken Grill Salad & Fries\", \"price\": 30000.00, \"item_id\": 2, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-22 10:00:00', '2026-06-29 19:26:26'),
(13, 'FNB-S000002', 'MBR-96018192', 'Aditya Pratama', '[{\"name\": \"Mix Salad Protein\", \"price\": 45000.00, \"item_id\": 3, \"quantity\": 1, \"subtotal\": 45000.00}]', 45000.00, 0.00, 0.00, 45000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-15 11:00:00', '2026-06-29 19:26:26'),
(14, 'FNB-S000003', 'MBR-21161094', 'Aisyah Lestari', '[{\"name\": \"Mix Vegetable Chicken Salad\", \"price\": 25000.00, \"item_id\": 4, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-08 12:00:00', '2026-06-29 19:26:26'),
(15, 'FNB-S000004', 'MBR-50921893', 'Akbar Santoso', '[{\"name\": \"Salmon Salad\", \"price\": 45000.00, \"item_id\": 5, \"quantity\": 1, \"subtotal\": 45000.00}]', 45000.00, 0.00, 0.00, 45000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-01 13:00:00', '2026-06-29 19:26:26'),
(16, 'FNB-S000005', 'MBR-15500595', 'Anindya Maharani', '[{\"name\": \"Healthy Food Salad\", \"price\": 45000.00, \"item_id\": 6, \"quantity\": 2, \"subtotal\": 90000.00}]', 90000.00, 0.00, 0.00, 90000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-25 14:00:00', '2026-06-29 19:26:26'),
(17, 'FNB-S000006', 'MBR-29429897', 'Bagas Saputra', '[{\"name\": \"Nasi Sapi Hitam\", \"price\": 30000.00, \"item_id\": 7, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-18 15:00:00', '2026-06-29 19:26:26'),
(18, 'FNB-S000007', 'MBR-11411615', 'Bella Kartika', '[{\"name\": \"Nasi Cabe Hijau\", \"price\": 30000.00, \"item_id\": 8, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-11 16:00:00', '2026-06-29 19:26:26'),
(19, 'FNB-S000008', 'MBR-12069006', 'Daffa Nugroho', '[{\"name\": \"Nasi Capcay\", \"price\": 30000.00, \"item_id\": 9, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-04 17:00:00', '2026-06-29 19:26:26'),
(20, 'FNB-S000009', 'MBR-33879704', 'Dewi Wulandari', '[{\"name\": \"Nasi Kung Pao Chicken\", \"price\": 30000.00, \"item_id\": 10, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-27 18:00:00', '2026-06-29 19:26:26'),
(21, 'FNB-S000010', 'MBR-82894411', 'Fajar Ramadhan', '[{\"name\": \"Honey Chicken Rice\", \"price\": 30000.00, \"item_id\": 11, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-20 09:00:00', '2026-06-29 19:26:26'),
(22, 'FNB-S000011', 'MBR-50960861', 'Fitri Permata', '[{\"name\": \"Nasi Sapi/Ayam Saus Tausi\", \"price\": 30000.00, \"item_id\": 12, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-13 10:00:00', '2026-06-29 19:26:26'),
(23, 'FNB-S000012', 'MBR-13047655', 'Galih Kusuma', '[{\"name\": \"Szechuan Chicken\", \"price\": 30000.00, \"item_id\": 13, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-06 11:00:00', '2026-06-29 19:26:26'),
(24, 'FNB-S000013', 'MBR-98420337', 'Intan Hidayat', '[{\"name\": \"Nasi Ayam Saus Asam Manis\", \"price\": 30000.00, \"item_id\": 14, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-28 12:00:00', '2026-06-29 19:26:26'),
(25, 'FNB-S000014', 'MBR-54193362', 'Kevin Puspita', '[{\"name\": \"Nasi Ayam Serundeng\", \"price\": 30000.00, \"item_id\": 15, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-21 13:00:00', '2026-06-29 19:26:26'),
(26, 'FNB-S000015', 'MBR-76485444', 'Lestari Firmansyah', '[{\"name\": \"Spaghetti Bolognese\", \"price\": 30000.00, \"item_id\": 16, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-14 14:00:00', '2026-06-29 19:26:26'),
(27, 'FNB-S000016', 'MBR-94067582', 'Muhammad Anggraini', '[{\"name\": \"Spaghetti Carbonara\", \"price\": 30000.00, \"item_id\": 17, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-07 15:00:00', '2026-06-29 19:26:26'),
(28, 'FNB-S000017', 'MBR-12061288', 'Nabila Setiawan', '[{\"name\": \"Spaghetti Aglio Olio Healthy Food\", \"price\": 40000.00, \"item_id\": 18, \"quantity\": 2, \"subtotal\": 80000.00}]', 80000.00, 0.00, 0.00, 80000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-31 16:00:00', '2026-06-29 19:26:26'),
(29, 'FNB-S000018', 'MBR-33680249', 'Raka Rahmawati', '[{\"name\": \"Indomie Rebus/Goreng Tanpa Telur\", \"price\": 10000.00, \"item_id\": 19, \"quantity\": 1, \"subtotal\": 10000.00}]', 10000.00, 0.00, 0.00, 10000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-24 17:00:00', '2026-06-29 19:26:26'),
(30, 'FNB-S000019', 'MBR-23204335', 'Salsabila Pratama', '[{\"name\": \"Paket Mie Rebus/Goreng Pakai Telur\", \"price\": 15000.00, \"item_id\": 20, \"quantity\": 2, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-17 18:00:00', '2026-06-29 19:26:26'),
(31, 'FNB-S000020', 'MBR-84434568', 'Yoga Lestari', '[{\"name\": \"Cireng RH\", \"price\": 20000.00, \"item_id\": 21, \"quantity\": 1, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-10 09:00:00', '2026-06-29 19:26:26'),
(32, 'FNB-S000021', 'MBR-56259230', 'Zahra Santoso', '[{\"name\": \"French Fries\", \"price\": 20000.00, \"item_id\": 22, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 0.00, 0.00, 40000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-03 10:00:00', '2026-06-29 19:26:26'),
(33, 'FNB-S000022', 'MBR-72268836', 'Aditya Maharani', '[{\"name\": \"Dimsum\", \"price\": 20000.00, \"item_id\": 23, \"quantity\": 1, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-26 11:00:00', '2026-06-29 19:26:26'),
(34, 'FNB-S000023', 'MBR-40746930', 'Aisyah Saputra', '[{\"name\": \"Pisang Goreng Wijen\", \"price\": 20000.00, \"item_id\": 24, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 0.00, 0.00, 40000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-19 12:00:00', '2026-06-29 19:26:26'),
(35, 'FNB-S000024', 'MBR-60465809', 'Akbar Kartika', '[{\"name\": \"Thai Fried Chicken\", \"price\": 28000.00, \"item_id\": 25, \"quantity\": 1, \"subtotal\": 28000.00}]', 28000.00, 0.00, 0.00, 28000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-12 13:00:00', '2026-06-29 19:26:26'),
(36, 'FNB-S000025', 'MBR-66500231', 'Anindya Nugroho', '[{\"name\": \"Chicken Wings\", \"price\": 25000.00, \"item_id\": 26, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-05 14:00:00', '2026-06-29 19:26:26'),
(37, 'FNB-S000026', 'MBR-27014589', 'Bagas Wulandari', '[{\"name\": \"Roti Bakar Manis\", \"price\": 15000.00, \"item_id\": 27, \"quantity\": 1, \"subtotal\": 15000.00}]', 15000.00, 0.00, 0.00, 15000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-27 15:00:00', '2026-06-29 19:26:26'),
(38, 'FNB-S000027', 'MBR-74436139', 'Bella Ramadhan', '[{\"name\": \"Lumpia RH\", \"price\": 25000.00, \"item_id\": 28, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-20 16:00:00', '2026-06-29 19:26:26'),
(39, 'FNB-S000028', 'MBR-99585082', 'Daffa Permata', '[{\"name\": \"Otak-Otak Goreng\", \"price\": 20000.00, \"item_id\": 29, \"quantity\": 1, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-13 17:00:00', '2026-06-29 19:26:26'),
(40, 'FNB-S000029', 'MBR-48911788', 'Dewi Kusuma', '[{\"name\": \"Bakwan Jagung\", \"price\": 18000.00, \"item_id\": 30, \"quantity\": 2, \"subtotal\": 36000.00}]', 36000.00, 0.00, 0.00, 36000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-06 18:00:00', '2026-06-29 19:26:26'),
(41, 'FNB-S000030', 'MBR-54205257', 'Fajar Hidayat', '[{\"name\": \"Americano\", \"price\": 25000.00, \"item_id\": 31, \"quantity\": 1, \"subtotal\": 25000.00}]', 25000.00, 0.00, 0.00, 25000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-30 09:00:00', '2026-06-29 19:26:26'),
(42, 'FNB-S000031', 'MBR-85973215', 'Fitri Puspita', '[{\"name\": \"Cappuccino\", \"price\": 28000.00, \"item_id\": 32, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 0.00, 0.00, 56000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-23 10:00:00', '2026-06-29 19:26:26'),
(43, 'FNB-S000032', 'MBR-44897893', 'Galih Firmansyah', '[{\"name\": \"Cafe Latte\", \"price\": 28000.00, \"item_id\": 33, \"quantity\": 1, \"subtotal\": 28000.00}]', 28000.00, 0.00, 0.00, 28000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-16 11:00:00', '2026-06-29 19:26:26'),
(44, 'FNB-S000033', 'MBR-72827763', 'Intan Anggraini', '[{\"name\": \"Vanilla Aren\", \"price\": 28000.00, \"item_id\": 34, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 0.00, 0.00, 56000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-09 12:00:00', '2026-06-29 19:26:26'),
(45, 'FNB-S000034', 'MBR-87861712', 'Kevin Setiawan', '[{\"name\": \"Banana Espresso\", \"price\": 35000.00, \"item_id\": 35, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-02 13:00:00', '2026-06-29 19:26:26'),
(46, 'FNB-S000035', 'MBR-40686150', 'Lestari Rahmawati', '[{\"name\": \"Matcha Latte\", \"price\": 28000.00, \"item_id\": 36, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 0.00, 0.00, 56000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-25 14:00:00', '2026-06-29 19:26:26'),
(47, 'FNB-S000036', 'MBR-55171708', 'Muhammad Pratama', '[{\"name\": \"Avocado Latte Espresso\", \"price\": 35000.00, \"item_id\": 37, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-18 15:00:00', '2026-06-29 19:26:26'),
(48, 'FNB-S000037', 'MBR-48891754', 'Nabila Lestari', '[{\"name\": \"Coklat Latte\", \"price\": 28000.00, \"item_id\": 38, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 0.00, 0.00, 56000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-11 16:00:00', '2026-06-29 19:26:26'),
(49, 'FNB-S000038', 'MBR-70264955', 'Raka Santoso', '[{\"name\": \"Vanilla Latte Ice\", \"price\": 25000.00, \"item_id\": 39, \"quantity\": 1, \"subtotal\": 25000.00}]', 25000.00, 0.00, 0.00, 25000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-04 17:00:00', '2026-06-29 19:26:26'),
(50, 'FNB-S000039', 'MBR-78748525', 'Salsabila Maharani', '[{\"name\": \"Pandan Coffee Latte\", \"price\": 30000.00, \"item_id\": 40, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-26 18:00:00', '2026-06-29 19:26:26'),
(51, 'FNB-S000040', 'MBR-39233678', 'Yoga Saputra', '[{\"name\": \"Hazelnut Coffee Latte\", \"price\": 28000.00, \"item_id\": 41, \"quantity\": 1, \"subtotal\": 28000.00}]', 28000.00, 0.00, 0.00, 28000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-19 09:00:00', '2026-06-29 19:26:26'),
(52, 'FNB-S000041', 'MBR-94058136', 'Zahra Kartika', '[{\"name\": \"Marie Regal Shake\", \"price\": 35000.00, \"item_id\": 42, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-12 10:00:00', '2026-06-29 19:26:26'),
(53, 'FNB-S000042', 'MBR-17986978', 'Aditya Nugroho', '[{\"name\": \"Oreo Cookies Cream\", \"price\": 35000.00, \"item_id\": 43, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-05 11:00:00', '2026-06-29 19:26:26'),
(54, 'FNB-S000043', 'MBR-89722932', 'Aisyah Wulandari', '[{\"name\": \"Green Tea\", \"price\": 28000.00, \"item_id\": 44, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 0.00, 0.00, 56000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-29 12:00:00', '2026-06-29 19:26:26'),
(55, 'FNB-S000044', 'MBR-91874455', 'Akbar Ramadhan', '[{\"name\": \"Lemon Tea\", \"price\": 25000.00, \"item_id\": 45, \"quantity\": 1, \"subtotal\": 25000.00}]', 25000.00, 0.00, 0.00, 25000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-22 13:00:00', '2026-06-29 19:26:26'),
(56, 'FNB-S000045', 'MBR-46690945', 'Anindya Permata', '[{\"name\": \"Lychee Tea\", \"price\": 28000.00, \"item_id\": 46, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 0.00, 0.00, 56000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-15 14:00:00', '2026-06-29 19:26:26'),
(57, 'FNB-S000046', 'MBR-93027387', 'Bagas Kusuma', '[{\"name\": \"Milky Brown Sugar\", \"price\": 30000.00, \"item_id\": 47, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-08 15:00:00', '2026-06-29 19:26:26'),
(58, 'FNB-S000047', 'MBR-17924525', 'Bella Hidayat', '[{\"name\": \"Salted Caramel Macchiato\", \"price\": 35000.00, \"item_id\": 48, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-01 16:00:00', '2026-06-29 19:26:26'),
(59, 'FNB-S000048', 'MBR-39160764', 'Daffa Puspita', '[{\"name\": \"Red Velvet\", \"price\": 35000.00, \"item_id\": 49, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-24 17:00:00', '2026-06-29 19:26:26'),
(60, 'FNB-S000049', 'MBR-26745258', 'Dewi Firmansyah', '[{\"name\": \"Mix Juice\", \"price\": 25000.00, \"item_id\": 50, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-17 18:00:00', '2026-06-29 19:26:26'),
(61, 'FNB-S000050', 'MBR-11330127', 'Fajar Anggraini', '[{\"name\": \"Ice Tea\", \"price\": 15000.00, \"item_id\": 51, \"quantity\": 1, \"subtotal\": 15000.00}]', 15000.00, 0.00, 0.00, 15000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-10 09:00:00', '2026-06-29 19:26:26'),
(62, 'FNB-S000051', 'MBR-29348185', 'Fitri Setiawan', '[{\"name\": \"Mineral Water\", \"price\": 10000.00, \"item_id\": 52, \"quantity\": 2, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-03 10:00:00', '2026-06-29 19:26:26'),
(63, 'FNB-S000052', 'MBR-80354147', 'Galih Rahmawati', '[{\"name\": \"Nasi Goreng Ala Rumah Hobi\", \"price\": 25000.00, \"item_id\": 53, \"quantity\": 1, \"subtotal\": 25000.00}]', 25000.00, 0.00, 0.00, 25000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-25 11:00:00', '2026-06-29 19:26:26'),
(64, 'FNB-S000053', 'MBR-25775221', 'Intan Pratama', '[{\"name\": \"Nasi Goreng Kecap\", \"price\": 25000.00, \"item_id\": 54, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-18 12:00:00', '2026-06-29 19:26:26'),
(65, 'FNB-S000054', 'MBR-29498966', 'Kevin Lestari', '[{\"name\": \"Nasi Goreng Ikan Asin\", \"price\": 30000.00, \"item_id\": 55, \"quantity\": 1, \"subtotal\": 30000.00}]', 30000.00, 0.00, 0.00, 30000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-11 13:00:00', '2026-06-29 19:26:26'),
(66, 'FNB-S000055', 'MBR-14355776', 'Lestari Santoso', '[{\"name\": \"Nasi Goreng Vegetarian\", \"price\": 30000.00, \"item_id\": 56, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-04 14:00:00', '2026-06-29 19:26:26'),
(67, 'FNB-S000056', 'MBR-33019770', 'Muhammad Maharani', '[{\"name\": \"Nasi Goreng Oriental\", \"price\": 35000.00, \"item_id\": 57, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-28 15:00:00', '2026-06-29 19:26:26'),
(68, 'FNB-S000057', 'MBR-78448748', 'Nabila Saputra', '[{\"name\": \"Nasi Goreng Kampung\", \"price\": 35000.00, \"item_id\": 58, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-21 16:00:00', '2026-06-29 19:26:26'),
(69, 'FNB-S000058', 'MBR-13739261', 'Raka Kartika', '[{\"name\": \"Nasi Goreng Singapore\", \"price\": 35000.00, \"item_id\": 59, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-14 17:00:00', '2026-06-29 19:26:26'),
(70, 'FNB-S000059', 'MBR-54779499', 'Salsabila Nugroho', '[{\"name\": \"Nasi Goreng Hongkong\", \"price\": 35000.00, \"item_id\": 60, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-07 18:00:00', '2026-06-29 19:26:26'),
(71, 'FNB-S000060', 'MBR-90812684', 'Yoga Wulandari', '[{\"name\": \"Nasi Goreng Seafood\", \"price\": 35000.00, \"item_id\": 61, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-30 09:00:00', '2026-06-29 19:26:26'),
(72, 'FNB-S000061', 'MBR-36153882', 'Zahra Ramadhan', '[{\"name\": \"Nasi Goreng Kebuli\", \"price\": 36000.00, \"item_id\": 62, \"quantity\": 2, \"subtotal\": 72000.00}]', 72000.00, 0.00, 0.00, 72000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-23 10:00:00', '2026-06-29 19:26:26'),
(73, 'FNB-S000062', 'MBR-53244320', 'Aditya Permata', '[{\"name\": \"Nasi Goreng Cabe Ijo Beef\", \"price\": 36000.00, \"item_id\": 63, \"quantity\": 1, \"subtotal\": 36000.00}]', 36000.00, 0.00, 0.00, 36000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-16 11:00:00', '2026-06-29 19:26:26'),
(74, 'FNB-S000063', 'MBR-48205878', 'Aisyah Kusuma', '[{\"name\": \"Kwetiau Goreng Kecap\", \"price\": 30000.00, \"item_id\": 64, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-09 12:00:00', '2026-06-29 19:26:26'),
(75, 'FNB-S000064', 'MBR-35313685', 'Akbar Hidayat', '[{\"name\": \"Kwetiau Siram\", \"price\": 35000.00, \"item_id\": 65, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-02 13:00:00', '2026-06-29 19:26:26'),
(76, 'FNB-S000065', 'MBR-15380611', 'Anindya Puspita', '[{\"name\": \"Kwetiau Goreng Kampung\", \"price\": 35000.00, \"item_id\": 66, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-24 14:00:00', '2026-06-29 19:26:26'),
(77, 'FNB-S000066', 'MBR-64813113', 'Bagas Firmansyah', '[{\"name\": \"Kwetiau Goreng Thailand\", \"price\": 35000.00, \"item_id\": 67, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-17 15:00:00', '2026-06-29 19:26:26'),
(78, 'FNB-S000067', 'MBR-48202159', 'Bella Anggraini', '[{\"name\": \"Kwetiau Goreng Singapore\", \"price\": 35000.00, \"item_id\": 68, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-10 16:00:00', '2026-06-29 19:26:26'),
(79, 'FNB-S000068', 'MBR-69683646', 'Daffa Setiawan', '[{\"name\": \"Garlic Kailan\", \"price\": 20000.00, \"item_id\": 69, \"quantity\": 1, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-03 17:00:00', '2026-06-29 19:26:26'),
(80, 'FNB-S000069', 'MBR-84091432', 'Dewi Rahmawati', '[{\"name\": \"Garlic Broccoli\", \"price\": 20000.00, \"item_id\": 70, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 0.00, 0.00, 40000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-27 18:00:00', '2026-06-29 19:26:26'),
(81, 'FNB-S000070', 'MBR-61631437', 'Fajar Pratama', '[{\"name\": \"Garlic Baby Kalian\", \"price\": 20000.00, \"item_id\": 71, \"quantity\": 1, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-20 09:00:00', '2026-06-29 19:26:26'),
(82, 'FNB-S000071', 'MBR-66915931', 'Fitri Lestari', '[{\"name\": \"Kailan With Oyster Sauce\", \"price\": 23000.00, \"item_id\": 72, \"quantity\": 2, \"subtotal\": 46000.00}]', 46000.00, 0.00, 0.00, 46000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-13 10:00:00', '2026-06-29 19:26:26'),
(83, 'FNB-S000072', 'MBR-24825313', 'Galih Santoso', '[{\"name\": \"Kangkung Balacan\", \"price\": 18000.00, \"item_id\": 73, \"quantity\": 1, \"subtotal\": 18000.00}]', 18000.00, 0.00, 0.00, 18000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-06 11:00:00', '2026-06-29 19:26:26'),
(84, 'FNB-S000073', 'MBR-79238647', 'Intan Maharani', '[{\"name\": \"Toge Cah Ikan Asin\", \"price\": 18000.00, \"item_id\": 74, \"quantity\": 2, \"subtotal\": 36000.00}]', 36000.00, 0.00, 0.00, 36000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-29 12:00:00', '2026-06-29 19:26:26'),
(85, 'FNB-S000074', 'MBR-61660500', 'Kevin Saputra', '[{\"name\": \"Buncis Cah Ayam/Ikan Asin\", \"price\": 20000.00, \"item_id\": 75, \"quantity\": 1, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-22 13:00:00', '2026-06-29 19:26:26'),
(86, 'FNB-S000075', 'MBR-78517442', 'Lestari Kartika', '[{\"name\": \"Mie Goreng Kampung\", \"price\": 35000.00, \"item_id\": 76, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-15 14:00:00', '2026-06-29 19:26:26'),
(87, 'FNB-S000076', 'MBR-94019320', 'Muhammad Nugroho', '[{\"name\": \"Mie Goreng Malaysia\", \"price\": 35000.00, \"item_id\": 77, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-08 15:00:00', '2026-06-29 19:26:26'),
(88, 'FNB-S000077', 'MBR-23706862', 'Nabila Wulandari', '[{\"name\": \"Mie Goreng Singapore\", \"price\": 35000.00, \"item_id\": 78, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-01 16:00:00', '2026-06-29 19:26:26'),
(89, 'FNB-S000078', 'MBR-39314431', 'Raka Ramadhan', '[{\"name\": \"Mie Goreng Cabe Garam\", \"price\": 35000.00, \"item_id\": 79, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-23 17:00:00', '2026-06-29 19:26:26'),
(90, 'FNB-S000079', 'MBR-22879081', 'Salsabila Permata', '[{\"name\": \"Mie Goreng Hongkong\", \"price\": 35000.00, \"item_id\": 80, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-16 18:00:00', '2026-06-29 19:26:26'),
(91, 'FNB-S000080', 'MBR-49809794', 'Yoga Kusuma', '[{\"name\": \"Mie Kuah Godog\", \"price\": 35000.00, \"item_id\": 81, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-09 09:00:00', '2026-06-29 19:26:26'),
(92, 'FNB-S000081', 'MBR-67330068', 'Zahra Hidayat', '[{\"name\": \"Mie Ayam\", \"price\": 30000.00, \"item_id\": 82, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-02 10:00:00', '2026-06-29 19:26:26'),
(93, 'FNB-S000082', 'MBR-17758382', 'Aditya Puspita', '[{\"name\": \"Mie Ayam Spesial\", \"price\": 35000.00, \"item_id\": 83, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-26 11:00:00', '2026-06-29 19:26:26'),
(94, 'FNB-S000083', 'MBR-37060664', 'Aisyah Firmansyah', '[{\"name\": \"Mie Ayam Wonton\", \"price\": 35000.00, \"item_id\": 84, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-19 12:00:00', '2026-06-29 19:26:26'),
(95, 'FNB-S000084', 'MBR-63117339', 'Akbar Anggraini', '[{\"name\": \"Bihun Kuah Godog\", \"price\": 25000.00, \"item_id\": 85, \"quantity\": 1, \"subtotal\": 25000.00}]', 25000.00, 0.00, 0.00, 25000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-12 13:00:00', '2026-06-29 19:26:26'),
(96, 'FNB-S000085', 'MBR-67754381', 'Anindya Setiawan', '[{\"name\": \"Bihun Goreng\", \"price\": 25000.00, \"item_id\": 86, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-05 14:00:00', '2026-06-29 19:26:26'),
(97, 'FNB-S000086', 'MBR-50786871', 'Bagas Rahmawati', '[{\"name\": \"Rice Bowl Sambal Geprek\", \"price\": 36000.00, \"item_id\": 87, \"quantity\": 1, \"subtotal\": 36000.00}]', 36000.00, 0.00, 0.00, 36000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-28 15:00:00', '2026-06-29 19:26:26'),
(98, 'FNB-S000087', 'MBR-15601313', 'Bella Pratama', '[{\"name\": \"Rice Bowl Cabe Garam\", \"price\": 35000.00, \"item_id\": 88, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-21 16:00:00', '2026-06-29 19:26:26'),
(99, 'FNB-S000088', 'MBR-82538800', 'Daffa Lestari', '[{\"name\": \"Rice Bowl Asam Manis\", \"price\": 35000.00, \"item_id\": 89, \"quantity\": 1, \"subtotal\": 35000.00}]', 35000.00, 0.00, 0.00, 35000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-14 17:00:00', '2026-06-29 19:26:26'),
(100, 'FNB-S000089', 'MBR-30992422', 'Dewi Santoso', '[{\"name\": \"Rice Bowl Sambel Matah\", \"price\": 34000.00, \"item_id\": 90, \"quantity\": 2, \"subtotal\": 68000.00}]', 68000.00, 0.00, 0.00, 68000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-07 18:00:00', '2026-06-29 19:26:26'),
(101, 'FNB-S000090', 'MBR-25699523', 'Fajar Maharani', '[{\"name\": \"Rice Bowl Cabe Hijau\", \"price\": 34000.00, \"item_id\": 91, \"quantity\": 1, \"subtotal\": 34000.00}]', 34000.00, 0.00, 0.00, 34000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-29 09:00:00', '2026-06-29 19:26:26'),
(102, 'FNB-S000091', 'MBR-96151253', 'Fitri Saputra', '[{\"name\": \"Rice Bowl Lada Hitam\", \"price\": 25000.00, \"item_id\": 92, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-22 10:00:00', '2026-06-29 19:26:26'),
(103, 'FNB-S000092', 'MBR-80788719', 'Galih Kartika', '[{\"name\": \"Rice Bowl Telur Asin\", \"price\": 36000.00, \"item_id\": 93, \"quantity\": 1, \"subtotal\": 36000.00}]', 36000.00, 0.00, 0.00, 36000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-15 11:00:00', '2026-06-29 19:26:26'),
(104, 'FNB-S000093', 'MBR-63513977', 'Intan Nugroho', '[{\"name\": \"Rice Bowl Beef Teriyaki\", \"price\": 35000.00, \"item_id\": 94, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 0.00, 0.00, 70000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-08 12:00:00', '2026-06-29 19:26:26'),
(105, 'FNB-S000094', 'MBR-94272986', 'Kevin Wulandari', '[{\"name\": \"Rice Bowl Ayam Serundeng\", \"price\": 36000.00, \"item_id\": 95, \"quantity\": 1, \"subtotal\": 36000.00}]', 36000.00, 0.00, 0.00, 36000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-01 13:00:00', '2026-06-29 19:26:26'),
(106, 'FNB-S000095', 'MBR-39212492', 'Lestari Ramadhan', '[{\"name\": \"Sapo Tofu\", \"price\": 30000.00, \"item_id\": 96, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 0.00, 0.00, 60000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-25 14:00:00', '2026-06-29 19:26:26'),
(107, 'FNB-S000096', 'MBR-81180278', 'Muhammad Permata', '[{\"name\": \"Moon Tofu\", \"price\": 28000.00, \"item_id\": 97, \"quantity\": 1, \"subtotal\": 28000.00}]', 28000.00, 0.00, 0.00, 28000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-18 15:00:00', '2026-06-29 19:26:26'),
(108, 'FNB-S000097', 'MBR-76788704', 'Nabila Kusuma', '[{\"name\": \"Tofu Cabe Garam\", \"price\": 28000.00, \"item_id\": 98, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 0.00, 0.00, 56000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-05-11 16:00:00', '2026-06-29 19:26:26'),
(109, 'FNB-S000098', 'MBR-53325041', 'Raka Hidayat', '[{\"name\": \"Chief Tofu\", \"price\": 25000.00, \"item_id\": 99, \"quantity\": 1, \"subtotal\": 25000.00}]', 25000.00, 0.00, 0.00, 25000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-05-04 17:00:00', '2026-06-29 19:26:26'),
(110, 'FNB-S000099', 'MBR-55496551', 'Salsabila Puspita', '[{\"name\": \"Nasi\", \"price\": 5000.00, \"item_id\": 102, \"quantity\": 2, \"subtotal\": 10000.00}]', 10000.00, 0.00, 0.00, 10000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-04-27 18:00:00', '2026-06-29 19:26:26'),
(111, 'FNB-S000100', 'MBR-35109378', 'Yoga Firmansyah', '[{\"name\": \"Telur\", \"price\": 5000.00, \"item_id\": 103, \"quantity\": 1, \"subtotal\": 5000.00}]', 5000.00, 0.00, 0.00, 5000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-04-20 09:00:00', '2026-06-29 19:26:26'),
(112, 'FNB-S000131', 'MBR-90010001', 'Renata Alexandra', '[{\"name\": \"Lumpia RH\", \"price\": 25000.00, \"item_id\": 28, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 0.00, 0.00, 50000.00, 'Cash', 'completed', 'Pembelian F&B', '2026-06-12 10:00:00', '2026-06-29 19:26:26'),
(113, 'FNB-S000132', 'MBR-90010002', 'Ananda Vionarmanta', '[{\"name\": \"Otak-Otak Goreng\", \"price\": 20000.00, \"item_id\": 29, \"quantity\": 1, \"subtotal\": 20000.00}]', 20000.00, 0.00, 0.00, 20000.00, 'QRIS', 'completed', 'Pembelian F&B', '2026-06-05 11:00:00', '2026-06-29 19:26:26'),
(139, 'FNB-V000017', 'MBR-12061288', 'Nabila Setiawan', '[{\"name\": \"Dimsum\", \"price\": 20000.00, \"item_id\": 23, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 14000.00, 0.00, 26000.00, 'QRIS', 'completed', 'Voucher F&B 35% - Nabila Setiawan', '2026-06-08 17:00:00', '2026-06-29 19:26:26'),
(140, 'FNB-V000008', 'MBR-12069006', 'Daffa Nugroho', '[{\"name\": \"Nasi Ayam Saus Asam Manis\", \"price\": 30000.00, \"item_id\": 14, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 6000.00, 0.00, 54000.00, 'QRIS', 'completed', 'Voucher F&B 10% - Daffa Nugroho', '2026-06-05 14:00:00', '2026-06-29 19:26:26'),
(141, 'FNB-V000012', 'MBR-13047655', 'Galih Kusuma', '[{\"name\": \"Spaghetti Aglio Olio Healthy Food\", \"price\": 40000.00, \"item_id\": 18, \"quantity\": 2, \"subtotal\": 80000.00}]', 80000.00, 36000.00, 0.00, 44000.00, 'QRIS', 'completed', 'Voucher F&B 45% - Galih Kusuma', '2026-06-23 12:00:00', '2026-06-29 19:26:26'),
(142, 'FNB-V000058', 'MBR-13739261', 'Raka Kartika', '[{\"name\": \"Kwetiau Goreng Kecap\", \"price\": 30000.00, \"item_id\": 64, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 6000.00, 0.00, 54000.00, 'QRIS', 'completed', 'Voucher F&B 10% - Raka Kartika', '2026-06-05 16:00:00', '2026-06-29 19:26:26'),
(143, 'FNB-V000055', 'MBR-14355776', 'Lestari Santoso', '[{\"name\": \"Nasi Goreng Seafood\", \"price\": 35000.00, \"item_id\": 61, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 24500.00, 0.00, 45500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Lestari Santoso', '2026-06-14 13:00:00', '2026-06-29 19:26:26'),
(144, 'FNB-V000065', 'MBR-15380611', 'Anindya Puspita', '[{\"name\": \"Garlic Baby Kalian\", \"price\": 20000.00, \"item_id\": 71, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 10000.00, 0.00, 30000.00, 'QRIS', 'completed', 'Voucher F&B 25% - Anindya Puspita', '2026-06-14 17:00:00', '2026-06-29 19:26:26'),
(145, 'FNB-V000005', 'MBR-15500595', 'Anindya Maharani', '[{\"name\": \"Honey Chicken Rice\", \"price\": 30000.00, \"item_id\": 11, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 21000.00, 0.00, 39000.00, 'QRIS', 'completed', 'Voucher F&B 35% - Anindya Maharani', '2026-06-14 17:00:00', '2026-06-29 19:26:26'),
(146, 'FNB-V000087', 'MBR-15601313', 'Bella Pratama', '[{\"name\": \"Rice Bowl Telur Asin\", \"price\": 36000.00, \"item_id\": 93, \"quantity\": 2, \"subtotal\": 72000.00}]', 72000.00, 32400.00, 0.00, 39600.00, 'QRIS', 'completed', 'Voucher F&B 45% - Bella Pratama', '2026-06-08 15:00:00', '2026-06-29 19:26:26'),
(147, 'FNB-V000047', 'MBR-17924525', 'Bella Hidayat', '[{\"name\": \"Nasi Goreng Ala Rumah Hobi\", \"price\": 25000.00, \"item_id\": 53, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 12500.00, 0.00, 37500.00, 'QRIS', 'completed', 'Voucher F&B 25% - Bella Hidayat', '2026-06-08 17:00:00', '2026-06-29 19:26:26'),
(148, 'FNB-V000042', 'MBR-17986978', 'Aditya Nugroho', '[{\"name\": \"Salted Caramel Macchiato\", \"price\": 35000.00, \"item_id\": 48, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 24500.00, 0.00, 45500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Aditya Nugroho', '2026-06-23 12:00:00', '2026-06-29 19:26:26'),
(149, 'FNB-V000003', 'MBR-21161094', 'Aisyah Lestari', '[{\"name\": \"Nasi Capcay\", \"price\": 30000.00, \"item_id\": 9, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 15000.00, 0.00, 45000.00, 'QRIS', 'completed', 'Voucher F&B 25% - Aisyah Lestari', '2026-06-20 15:00:00', '2026-06-29 19:26:26'),
(150, 'FNB-V000079', 'MBR-22879081', 'Salsabila Permata', '[{\"name\": \"Bihun Kuah Godog\", \"price\": 25000.00, \"item_id\": 85, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 17500.00, 0.00, 32500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Salsabila Permata', '2026-06-02 13:00:00', '2026-06-29 19:26:26'),
(151, 'FNB-V000077', 'MBR-23706862', 'Nabila Wulandari', '[{\"name\": \"Mie Ayam Spesial\", \"price\": 35000.00, \"item_id\": 83, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 7000.00, 0.00, 63000.00, 'QRIS', 'completed', 'Voucher F&B 10% - Nabila Wulandari', '2026-06-08 17:00:00', '2026-06-29 19:26:26'),
(152, 'FNB-V000072', 'MBR-24825313', 'Galih Santoso', '[{\"name\": \"Mie Goreng Singapore\", \"price\": 35000.00, \"item_id\": 78, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 17500.00, 0.00, 52500.00, 'QRIS', 'completed', 'Voucher F&B 25% - Galih Santoso', '2026-06-23 12:00:00', '2026-06-29 19:26:26'),
(153, 'FNB-V000090', 'MBR-25699523', 'Fajar Maharani', '[{\"name\": \"Sapo Tofu\", \"price\": 30000.00, \"item_id\": 96, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 15000.00, 0.00, 45000.00, 'QRIS', 'completed', 'Voucher F&B 25% - Fajar Maharani', '2026-06-29 12:00:00', '2026-06-29 19:26:26'),
(154, 'FNB-V000053', 'MBR-25775221', 'Intan Pratama', '[{\"name\": \"Nasi Goreng Singapore\", \"price\": 35000.00, \"item_id\": 59, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 17500.00, 0.00, 52500.00, 'QRIS', 'completed', 'Voucher F&B 25% - Intan Pratama', '2026-06-20 17:00:00', '2026-06-29 19:26:26'),
(155, 'FNB-V000049', 'MBR-26745258', 'Dewi Firmansyah', '[{\"name\": \"Nasi Goreng Ikan Asin\", \"price\": 30000.00, \"item_id\": 55, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 27000.00, 0.00, 33000.00, 'QRIS', 'completed', 'Voucher F&B 45% - Dewi Firmansyah', '2026-06-02 13:00:00', '2026-06-29 19:26:26'),
(156, 'FNB-V000006', 'MBR-29429897', 'Bagas Saputra', '[{\"name\": \"Nasi Sapi/Ayam Saus Tausi\", \"price\": 30000.00, \"item_id\": 12, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 27000.00, 0.00, 33000.00, 'QRIS', 'completed', 'Voucher F&B 45% - Bagas Saputra', '2026-06-11 12:00:00', '2026-06-29 19:26:26'),
(157, 'FNB-V000054', 'MBR-29498966', 'Kevin Lestari', '[{\"name\": \"Nasi Goreng Hongkong\", \"price\": 35000.00, \"item_id\": 60, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 24500.00, 0.00, 45500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Kevin Lestari', '2026-06-17 12:00:00', '2026-06-29 19:26:26'),
(158, 'FNB-V000089', 'MBR-30992422', 'Dewi Santoso', '[{\"name\": \"Rice Bowl Ayam Serundeng\", \"price\": 36000.00, \"item_id\": 95, \"quantity\": 2, \"subtotal\": 72000.00}]', 72000.00, 7200.00, 0.00, 64800.00, 'QRIS', 'completed', 'Voucher F&B 10% - Dewi Santoso', '2026-06-02 17:00:00', '2026-06-29 19:26:26'),
(159, 'FNB-V000018', 'MBR-33680249', 'Raka Rahmawati', '[{\"name\": \"Pisang Goreng Wijen\", \"price\": 20000.00, \"item_id\": 24, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 18000.00, 0.00, 22000.00, 'QRIS', 'completed', 'Voucher F&B 45% - Raka Rahmawati', '2026-06-05 12:00:00', '2026-06-29 19:26:26'),
(160, 'FNB-V000009', 'MBR-33879704', 'Dewi Wulandari', '[{\"name\": \"Nasi Ayam Serundeng\", \"price\": 30000.00, \"item_id\": 15, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 15000.00, 0.00, 45000.00, 'QRIS', 'completed', 'Voucher F&B 25% - Dewi Wulandari', '2026-06-02 15:00:00', '2026-06-29 19:26:26'),
(161, 'FNB-V000064', 'MBR-35313685', 'Akbar Hidayat', '[{\"name\": \"Garlic Broccoli\", \"price\": 20000.00, \"item_id\": 70, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 4000.00, 0.00, 36000.00, 'QRIS', 'completed', 'Voucher F&B 10% - Akbar Hidayat', '2026-06-17 16:00:00', '2026-06-29 19:26:26'),
(162, 'FNB-V000061', 'MBR-36153882', 'Zahra Ramadhan', '[{\"name\": \"Kwetiau Goreng Thailand\", \"price\": 35000.00, \"item_id\": 67, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 24500.00, 0.00, 45500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Zahra Ramadhan', '2026-06-26 13:00:00', '2026-06-29 19:26:26'),
(163, 'FNB-V000083', 'MBR-37060664', 'Aisyah Firmansyah', '[{\"name\": \"Rice Bowl Asam Manis\", \"price\": 35000.00, \"item_id\": 89, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 7000.00, 0.00, 63000.00, 'QRIS', 'completed', 'Voucher F&B 10% - Aisyah Firmansyah', '2026-06-20 17:00:00', '2026-06-29 19:26:26'),
(164, 'FNB-V000048', 'MBR-39160764', 'Daffa Puspita', '[{\"name\": \"Nasi Goreng Kecap\", \"price\": 25000.00, \"item_id\": 54, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 17500.00, 0.00, 32500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Daffa Puspita', '2026-06-05 12:00:00', '2026-06-29 19:26:26'),
(165, 'FNB-V000095', 'MBR-39212492', 'Lestari Ramadhan', '[{\"name\": \"Telur\", \"price\": 5000.00, \"item_id\": 103, \"quantity\": 2, \"subtotal\": 10000.00}]', 10000.00, 1000.00, 0.00, 9000.00, 'QRIS', 'completed', 'Voucher F&B 10% - Lestari Ramadhan', '2026-06-14 17:00:00', '2026-06-29 19:26:26'),
(166, 'FNB-V000040', 'MBR-39233678', 'Yoga Saputra', '[{\"name\": \"Lychee Tea\", \"price\": 28000.00, \"item_id\": 46, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 14000.00, 0.00, 42000.00, 'QRIS', 'completed', 'Voucher F&B 25% - Yoga Saputra', '2026-06-29 16:00:00', '2026-06-29 19:26:26'),
(167, 'FNB-V000078', 'MBR-39314431', 'Raka Ramadhan', '[{\"name\": \"Mie Ayam Wonton\", \"price\": 35000.00, \"item_id\": 84, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 17500.00, 0.00, 52500.00, 'QRIS', 'completed', 'Voucher F&B 25% - Raka Ramadhan', '2026-06-05 12:00:00', '2026-06-29 19:26:26'),
(168, 'FNB-V000035', 'MBR-40686150', 'Lestari Rahmawati', '[{\"name\": \"Hazelnut Coffee Latte\", \"price\": 28000.00, \"item_id\": 41, \"quantity\": 2, \"subtotal\": 56000.00}]', 56000.00, 14000.00, 0.00, 42000.00, 'QRIS', 'completed', 'Voucher F&B 25% - Lestari Rahmawati', '2026-06-14 17:00:00', '2026-06-29 19:26:26'),
(169, 'FNB-V000023', 'MBR-40746930', 'Aisyah Saputra', '[{\"name\": \"Otak-Otak Goreng\", \"price\": 20000.00, \"item_id\": 29, \"quantity\": 2, \"subtotal\": 40000.00}]', 40000.00, 14000.00, 0.00, 26000.00, 'QRIS', 'completed', 'Voucher F&B 35% - Aisyah Saputra', '2026-06-20 17:00:00', '2026-06-29 19:26:26'),
(170, 'FNB-V000045', 'MBR-46690945', 'Anindya Permata', '[{\"name\": \"Ice Tea\", \"price\": 15000.00, \"item_id\": 51, \"quantity\": 2, \"subtotal\": 30000.00}]', 30000.00, 3000.00, 0.00, 27000.00, 'QRIS', 'completed', 'Voucher F&B 10% - Anindya Permata', '2026-06-14 15:00:00', '2026-06-29 19:26:26'),
(171, 'FNB-V000067', 'MBR-48202159', 'Bella Anggraini', '[{\"name\": \"Kangkung Balacan\", \"price\": 18000.00, \"item_id\": 73, \"quantity\": 2, \"subtotal\": 36000.00}]', 36000.00, 12600.00, 0.00, 23400.00, 'QRIS', 'completed', 'Voucher F&B 35% - Bella Anggraini', '2026-06-08 13:00:00', '2026-06-29 19:26:26'),
(172, 'FNB-V000037', 'MBR-48891754', 'Nabila Lestari', '[{\"name\": \"Oreo Cookies Cream\", \"price\": 35000.00, \"item_id\": 43, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 31500.00, 0.00, 38500.00, 'QRIS', 'completed', 'Voucher F&B 45% - Nabila Lestari', '2026-06-08 13:00:00', '2026-06-29 19:26:26'),
(173, 'FNB-V000029', 'MBR-48911788', 'Dewi Kusuma', '[{\"name\": \"Banana Espresso\", \"price\": 35000.00, \"item_id\": 35, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 24500.00, 0.00, 45500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Dewi Kusuma', '2026-06-02 17:00:00', '2026-06-29 19:26:26'),
(174, 'FNB-V000080', 'MBR-49809794', 'Yoga Kusuma', '[{\"name\": \"Bihun Goreng\", \"price\": 25000.00, \"item_id\": 86, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 22500.00, 0.00, 27500.00, 'QRIS', 'completed', 'Voucher F&B 45% - Yoga Kusuma', '2026-06-29 14:00:00', '2026-06-29 19:26:26'),
(175, 'FNB-V000086', 'MBR-50786871', 'Bagas Rahmawati', '[{\"name\": \"Rice Bowl Lada Hitam\", \"price\": 25000.00, \"item_id\": 92, \"quantity\": 2, \"subtotal\": 50000.00}]', 50000.00, 17500.00, 0.00, 32500.00, 'QRIS', 'completed', 'Voucher F&B 35% - Bagas Rahmawati', '2026-06-11 14:00:00', '2026-06-29 19:26:26'),
(176, 'FNB-V000004', 'MBR-50921893', 'Akbar Santoso', '[{\"name\": \"Nasi Kung Pao Chicken\", \"price\": 30000.00, \"item_id\": 10, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 15000.00, 0.00, 45000.00, 'QRIS', 'completed', 'Voucher F&B 25% - Akbar Santoso', '2026-06-17 16:00:00', '2026-06-29 19:26:26'),
(177, 'FNB-V000011', 'MBR-50960861', 'Fitri Permata', '[{\"name\": \"Spaghetti Carbonara\", \"price\": 30000.00, \"item_id\": 17, \"quantity\": 2, \"subtotal\": 60000.00}]', 60000.00, 21000.00, 0.00, 39000.00, 'QRIS', 'completed', 'Voucher F&B 35% - Fitri Permata', '2026-06-26 17:00:00', '2026-06-29 19:26:26'),
(178, 'FNB-V000062', 'MBR-53244320', 'Aditya Permata', '[{\"name\": \"Kwetiau Goreng Singapore\", \"price\": 35000.00, \"item_id\": 68, \"quantity\": 2, \"subtotal\": 70000.00}]', 70000.00, 31500.00, 0.00, 38500.00, 'QRIS', 'completed', 'Voucher F&B 45% - Aditya Permata', '2026-06-23 14:00:00', '2026-06-29 19:26:26');

-- --------------------------------------------------------

--
-- Table structure for table `gym_packages`
--

CREATE TABLE `gym_packages` (
  `id` bigint UNSIGNED NOT NULL,
  `package_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(12,2) UNSIGNED NOT NULL,
  `package_type` enum('membership','daily') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_days` smallint UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `gym_packages`
--

INSERT INTO `gym_packages` (`id`, `package_code`, `package_name`, `description`, `price`, `package_type`, `duration_days`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'PKG-DAILY', 'Daily Pass', 'Akses gym untuk satu kali kunjungan', 60000.00, 'daily', 1, 1, '2026-06-21 16:05:41', '2026-06-21 16:05:41'),
(2, 'PKG-001', 'Paket 1 Bulan', 'Akses gym penuh selama 30 hari', 199000.00, 'membership', 30, 1, '2026-06-21 16:05:41', '2026-06-21 16:05:41'),
(3, 'PKG-002', 'Paket 2 Bulan', 'Akses gym penuh selama 60 hari', 379000.00, 'membership', 60, 1, '2026-06-21 16:05:41', '2026-06-21 16:05:41'),
(4, 'PKG-003', 'Paket 4 Bulan', 'Akses gym penuh selama 120 hari', 699000.00, 'membership', 120, 1, '2026-06-21 16:05:41', '2026-06-21 16:05:41'),
(5, 'PKG-004', 'Paket 6 Bulan', 'Akses gym penuh selama 180 hari', 999000.00, 'membership', 180, 1, '2026-06-21 16:05:41', '2026-06-21 16:05:41'),
(6, 'PKG-005', 'Paket 1 Tahun', 'Akses gym penuh selama 365 hari', 1799000.00, 'membership', 365, 1, '2026-06-21 16:05:41', '2026-06-21 16:05:41');

-- --------------------------------------------------------

--
-- Table structure for table `gym_transactions`
--

CREATE TABLE `gym_transactions` (
  `id` bigint UNSIGNED NOT NULL,
  `transaction_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `member_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `package_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `amount` decimal(12,2) UNSIGNED NOT NULL,
  `admin_fee` decimal(12,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `payment_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'completed',
  `notes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gym_transactions`
--

INSERT INTO `gym_transactions` (`id`, `transaction_code`, `member_code`, `package_code`, `customer_type`, `customer_name`, `amount`, `admin_fee`, `payment_method`, `status`, `notes`, `transaction_date`, `created_at`) VALUES
(2, 'GYM-6E008055BC', 'MBR-58310427', 'PKG-002', 'member', 'Sabrilia Melda', 379000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan member', '2026-06-25 08:05:19', '2026-06-25 08:05:19'),
(3, 'GYM-89863CD6D6', 'MBR-17758382', 'PKG-001', 'member', 'Aditya Puspita', 199000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan member', '2026-06-25 08:15:33', '2026-06-25 08:15:33'),
(4, 'GYM-AE539CF546', 'MBR-14355776', 'PKG-001', 'member', 'Lestari Santoso', 199000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan member', '2026-06-25 08:16:28', '2026-06-25 08:16:28'),
(5, 'GYM-B5FA1C641B', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan member', '2026-06-25 16:10:59', '2026-06-25 16:10:59'),
(6, 'GYM-3282BE93E1', NULL, 'PKG-002', 'new', 'Member Baru', 479000.00, 100000.00, 'QRIS', 'completed', 'Pembayaran member baru | Data diri via QR registrasi kasir', '2026-06-25 18:02:11', '2026-06-25 18:02:11'),
(7, 'GYM-21FC0C58D4', NULL, 'PKG-001', 'new', 'Member Baru', 299000.00, 100000.00, 'QRIS', 'completed', 'Pembayaran member baru | Data diri via QR registrasi kasir', '2026-06-27 01:39:58', '2026-06-27 01:39:58'),
(9, 'GYM-BD12354BDC', NULL, 'PKG-001', 'new', 'Adinda', 299000.00, 100000.00, 'QRIS', 'completed', 'Pembayaran member baru | Data diri via QR registrasi kasir', '2026-06-27 10:53:34', '2026-06-27 10:53:34'),
(10, 'GYM-R0000001', 'MBR-58310427', 'PKG-001', 'new', 'Sabrilia Melda', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-09-30 09:00:00', '2026-06-29 19:19:49'),
(11, 'GYM-R0000002', 'MBR-96018192', 'PKG-001', 'new', 'Aditya Pratama', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2026-05-10 10:00:00', '2026-06-29 19:19:49'),
(12, 'GYM-R0000003', 'MBR-21161094', 'PKG-002', 'new', 'Aisyah Lestari', 379000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2026-05-03 11:00:00', '2026-06-29 19:19:49'),
(13, 'GYM-R0000004', 'MBR-50921893', 'PKG-003', 'new', 'Akbar Santoso', 699000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2026-04-26 12:00:00', '2026-06-29 19:19:49'),
(14, 'GYM-R0000005', 'MBR-15500595', 'PKG-004', 'new', 'Anindya Maharani', 999000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2026-04-19 13:00:00', '2026-06-29 19:19:49'),
(15, 'GYM-R0000006', 'MBR-29429897', 'PKG-005', 'new', 'Bagas Saputra', 1799000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2026-04-12 14:00:00', '2026-06-29 19:19:49'),
(16, 'GYM-R0000007', 'MBR-11411615', 'PKG-001', 'new', 'Bella Kartika', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2026-04-05 15:00:00', '2026-06-29 19:19:49'),
(17, 'GYM-R0000008', 'MBR-12069006', 'PKG-002', 'new', 'Daffa Nugroho', 379000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2026-03-29 16:00:00', '2026-06-29 19:19:49'),
(18, 'GYM-R0000009', 'MBR-33879704', 'PKG-003', 'new', 'Dewi Wulandari', 699000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2026-03-22 17:00:00', '2026-06-29 19:19:49'),
(19, 'GYM-R0000010', 'MBR-82894411', 'PKG-004', 'new', 'Fajar Ramadhan', 999000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2026-03-15 18:00:00', '2026-06-29 19:19:49'),
(20, 'GYM-R0000011', 'MBR-50960861', 'PKG-005', 'new', 'Fitri Permata', 1799000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2026-03-08 08:00:00', '2026-06-29 19:19:49'),
(21, 'GYM-R0000012', 'MBR-13047655', 'PKG-001', 'new', 'Galih Kusuma', 199000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2026-03-01 09:00:00', '2026-06-29 19:19:49'),
(22, 'GYM-R0000013', 'MBR-98420337', 'PKG-002', 'new', 'Intan Hidayat', 379000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2026-02-22 10:00:00', '2026-06-29 19:19:49'),
(23, 'GYM-R0000014', 'MBR-54193362', 'PKG-003', 'new', 'Kevin Puspita', 699000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2026-02-15 11:00:00', '2026-06-29 19:19:49'),
(24, 'GYM-R0000015', 'MBR-76485444', 'PKG-004', 'new', 'Lestari Firmansyah', 999000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2026-02-08 12:00:00', '2026-06-29 19:19:49'),
(25, 'GYM-R0000016', 'MBR-94067582', 'PKG-005', 'new', 'Muhammad Anggraini', 1799000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2026-02-01 13:00:00', '2026-06-29 19:19:49'),
(26, 'GYM-R0000017', 'MBR-12061288', 'PKG-001', 'new', 'Nabila Setiawan', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2026-01-25 14:00:00', '2026-06-29 19:19:49'),
(27, 'GYM-R0000018', 'MBR-33680249', 'PKG-002', 'new', 'Raka Rahmawati', 379000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2026-01-18 15:00:00', '2026-06-29 19:19:49'),
(28, 'GYM-R0000019', 'MBR-23204335', 'PKG-003', 'new', 'Salsabila Pratama', 699000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2026-01-11 16:00:00', '2026-06-29 19:19:49'),
(29, 'GYM-R0000020', 'MBR-84434568', 'PKG-004', 'new', 'Yoga Lestari', 999000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2026-01-04 17:00:00', '2026-06-29 19:19:49'),
(30, 'GYM-R0000021', 'MBR-56259230', 'PKG-005', 'new', 'Zahra Santoso', 1799000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-12-28 18:00:00', '2026-06-29 19:19:49'),
(31, 'GYM-R0000022', 'MBR-72268836', 'PKG-001', 'new', 'Aditya Maharani', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-12-21 08:00:00', '2026-06-29 19:19:49'),
(32, 'GYM-R0000023', 'MBR-40746930', 'PKG-002', 'new', 'Aisyah Saputra', 379000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-12-14 09:00:00', '2026-06-29 19:19:49'),
(33, 'GYM-R0000024', 'MBR-60465809', 'PKG-003', 'new', 'Akbar Kartika', 699000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-12-07 10:00:00', '2026-06-29 19:19:49'),
(34, 'GYM-R0000025', 'MBR-66500231', 'PKG-004', 'new', 'Anindya Nugroho', 999000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-11-30 11:00:00', '2026-06-29 19:19:49'),
(35, 'GYM-R0000026', 'MBR-27014589', 'PKG-005', 'new', 'Bagas Wulandari', 1799000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-11-23 12:00:00', '2026-06-29 19:19:49'),
(36, 'GYM-R0000027', 'MBR-74436139', 'PKG-001', 'new', 'Bella Ramadhan', 199000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-11-16 13:00:00', '2026-06-29 19:19:49'),
(37, 'GYM-R0000028', 'MBR-99585082', 'PKG-002', 'new', 'Daffa Permata', 379000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-11-09 14:00:00', '2026-06-29 19:19:49'),
(38, 'GYM-R0000029', 'MBR-48911788', 'PKG-003', 'new', 'Dewi Kusuma', 699000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-11-02 15:00:00', '2026-06-29 19:19:49'),
(39, 'GYM-R0000030', 'MBR-54205257', 'PKG-004', 'new', 'Fajar Hidayat', 999000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-10-26 16:00:00', '2026-06-29 19:19:49'),
(40, 'GYM-R0000031', 'MBR-85973215', 'PKG-005', 'new', 'Fitri Puspita', 1799000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-10-19 17:00:00', '2026-06-29 19:19:49'),
(41, 'GYM-R0000032', 'MBR-44897893', 'PKG-001', 'new', 'Galih Firmansyah', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-10-12 18:00:00', '2026-06-29 19:19:49'),
(42, 'GYM-R0000033', 'MBR-72827763', 'PKG-002', 'new', 'Intan Anggraini', 379000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-10-05 08:00:00', '2026-06-29 19:19:49'),
(43, 'GYM-R0000034', 'MBR-87861712', 'PKG-003', 'new', 'Kevin Setiawan', 699000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-09-28 09:00:00', '2026-06-29 19:19:49'),
(44, 'GYM-R0000035', 'MBR-40686150', 'PKG-004', 'new', 'Lestari Rahmawati', 999000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-09-21 10:00:00', '2026-06-29 19:19:49'),
(45, 'GYM-R0000036', 'MBR-55171708', 'PKG-005', 'new', 'Muhammad Pratama', 1799000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-09-14 11:00:00', '2026-06-29 19:19:49'),
(46, 'GYM-R0000037', 'MBR-48891754', 'PKG-001', 'new', 'Nabila Lestari', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-09-07 12:00:00', '2026-06-29 19:19:49'),
(47, 'GYM-R0000038', 'MBR-70264955', 'PKG-002', 'new', 'Raka Santoso', 379000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-08-31 13:00:00', '2026-06-29 19:19:49'),
(48, 'GYM-R0000039', 'MBR-78748525', 'PKG-003', 'new', 'Salsabila Maharani', 699000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-08-24 14:00:00', '2026-06-29 19:19:49'),
(49, 'GYM-R0000040', 'MBR-39233678', 'PKG-004', 'new', 'Yoga Saputra', 999000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-08-17 15:00:00', '2026-06-29 19:19:49'),
(50, 'GYM-R0000041', 'MBR-94058136', 'PKG-005', 'new', 'Zahra Kartika', 1799000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-08-10 16:00:00', '2026-06-29 19:19:49'),
(51, 'GYM-R0000042', 'MBR-17986978', 'PKG-001', 'new', 'Aditya Nugroho', 199000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-08-03 17:00:00', '2026-06-29 19:19:49'),
(52, 'GYM-R0000043', 'MBR-89722932', 'PKG-002', 'new', 'Aisyah Wulandari', 379000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-07-27 18:00:00', '2026-06-29 19:19:49'),
(53, 'GYM-R0000044', 'MBR-91874455', 'PKG-003', 'new', 'Akbar Ramadhan', 699000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-07-20 08:00:00', '2026-06-29 19:19:49'),
(54, 'GYM-R0000045', 'MBR-46690945', 'PKG-004', 'new', 'Anindya Permata', 999000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-07-13 09:00:00', '2026-06-29 19:19:49'),
(55, 'GYM-R0000046', 'MBR-93027387', 'PKG-005', 'new', 'Bagas Kusuma', 1799000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-07-06 10:00:00', '2026-06-29 19:19:49'),
(56, 'GYM-R0000047', 'MBR-17924525', 'PKG-001', 'new', 'Bella Hidayat', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-06-29 11:00:00', '2026-06-29 19:19:49'),
(57, 'GYM-R0000048', 'MBR-39160764', 'PKG-002', 'new', 'Daffa Puspita', 379000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-06-22 12:00:00', '2026-06-29 19:19:49'),
(58, 'GYM-R0000049', 'MBR-26745258', 'PKG-003', 'new', 'Dewi Firmansyah', 699000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-06-15 13:00:00', '2026-06-29 19:19:49'),
(59, 'GYM-R0000050', 'MBR-11330127', 'PKG-004', 'new', 'Fajar Anggraini', 999000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-06-08 14:00:00', '2026-06-29 19:19:49'),
(60, 'GYM-R0000051', 'MBR-29348185', 'PKG-005', 'new', 'Fitri Setiawan', 1799000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-06-01 15:00:00', '2026-06-29 19:19:49'),
(61, 'GYM-R0000052', 'MBR-80354147', 'PKG-001', 'new', 'Galih Rahmawati', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-05-25 16:00:00', '2026-06-29 19:19:49'),
(62, 'GYM-R0000053', 'MBR-25775221', 'PKG-002', 'new', 'Intan Pratama', 379000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-05-18 17:00:00', '2026-06-29 19:19:49'),
(63, 'GYM-R0000054', 'MBR-29498966', 'PKG-003', 'new', 'Kevin Lestari', 699000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-05-11 18:00:00', '2026-06-29 19:19:49'),
(64, 'GYM-R0000055', 'MBR-14355776', 'PKG-001', 'new', 'Lestari Santoso', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-05-04 08:00:00', '2026-06-29 19:19:49'),
(65, 'GYM-R0000056', 'MBR-33019770', 'PKG-005', 'new', 'Muhammad Maharani', 1799000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-04-27 09:00:00', '2026-06-29 19:19:49'),
(66, 'GYM-R0000057', 'MBR-78448748', 'PKG-001', 'new', 'Nabila Saputra', 199000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-04-20 10:00:00', '2026-06-29 19:19:49'),
(67, 'GYM-R0000058', 'MBR-13739261', 'PKG-002', 'new', 'Raka Kartika', 379000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-04-13 11:00:00', '2026-06-29 19:19:49'),
(68, 'GYM-R0000059', 'MBR-54779499', 'PKG-003', 'new', 'Salsabila Nugroho', 699000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-04-06 12:00:00', '2026-06-29 19:19:49'),
(69, 'GYM-R0000060', 'MBR-90812684', 'PKG-004', 'new', 'Yoga Wulandari', 999000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-03-30 13:00:00', '2026-06-29 19:19:49'),
(70, 'GYM-R0000061', 'MBR-36153882', 'PKG-005', 'new', 'Zahra Ramadhan', 1799000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-03-23 14:00:00', '2026-06-29 19:19:49'),
(71, 'GYM-R0000062', 'MBR-53244320', 'PKG-001', 'new', 'Aditya Permata', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-03-16 15:00:00', '2026-06-29 19:19:49'),
(72, 'GYM-R0000063', 'MBR-48205878', 'PKG-002', 'new', 'Aisyah Kusuma', 379000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-03-09 16:00:00', '2026-06-29 19:19:49'),
(73, 'GYM-R0000064', 'MBR-35313685', 'PKG-003', 'new', 'Akbar Hidayat', 699000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-03-02 17:00:00', '2026-06-29 19:19:49'),
(74, 'GYM-R0000065', 'MBR-15380611', 'PKG-004', 'new', 'Anindya Puspita', 999000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-02-23 18:00:00', '2026-06-29 19:19:49'),
(75, 'GYM-R0000066', 'MBR-64813113', 'PKG-005', 'new', 'Bagas Firmansyah', 1799000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-02-16 08:00:00', '2026-06-29 19:19:49'),
(76, 'GYM-R0000067', 'MBR-48202159', 'PKG-001', 'new', 'Bella Anggraini', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-02-09 09:00:00', '2026-06-29 19:19:49'),
(77, 'GYM-R0000068', 'MBR-69683646', 'PKG-002', 'new', 'Daffa Setiawan', 379000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2025-02-02 10:00:00', '2026-06-29 19:19:49'),
(78, 'GYM-R0000069', 'MBR-84091432', 'PKG-003', 'new', 'Dewi Rahmawati', 699000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2025-01-26 11:00:00', '2026-06-29 19:19:49'),
(79, 'GYM-R0000070', 'MBR-61631437', 'PKG-004', 'new', 'Fajar Pratama', 999000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2025-01-19 12:00:00', '2026-06-29 19:19:49'),
(80, 'GYM-R0000071', 'MBR-66915931', 'PKG-005', 'new', 'Fitri Lestari', 1799000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2025-01-12 13:00:00', '2026-06-29 19:19:49'),
(81, 'GYM-R0000072', 'MBR-24825313', 'PKG-001', 'new', 'Galih Santoso', 199000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2025-01-05 14:00:00', '2026-06-29 19:19:49'),
(82, 'GYM-R0000073', 'MBR-79238647', 'PKG-002', 'new', 'Intan Maharani', 379000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2024-12-29 15:00:00', '2026-06-29 19:19:49'),
(83, 'GYM-R0000074', 'MBR-61660500', 'PKG-003', 'new', 'Kevin Saputra', 699000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2024-12-22 16:00:00', '2026-06-29 19:19:49'),
(84, 'GYM-R0000075', 'MBR-78517442', 'PKG-004', 'new', 'Lestari Kartika', 999000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2024-12-15 17:00:00', '2026-06-29 19:19:49'),
(85, 'GYM-R0000076', 'MBR-94019320', 'PKG-005', 'new', 'Muhammad Nugroho', 1799000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2024-12-08 18:00:00', '2026-06-29 19:19:49'),
(86, 'GYM-R0000077', 'MBR-23706862', 'PKG-001', 'new', 'Nabila Wulandari', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2024-12-01 08:00:00', '2026-06-29 19:19:49'),
(87, 'GYM-R0000078', 'MBR-39314431', 'PKG-002', 'new', 'Raka Ramadhan', 379000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2024-11-24 09:00:00', '2026-06-29 19:19:49'),
(88, 'GYM-R0000079', 'MBR-22879081', 'PKG-003', 'new', 'Salsabila Permata', 699000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2024-11-17 10:00:00', '2026-06-29 19:19:49'),
(89, 'GYM-R0000080', 'MBR-49809794', 'PKG-004', 'new', 'Yoga Kusuma', 999000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2024-11-10 11:00:00', '2026-06-29 19:19:49'),
(90, 'GYM-R0000081', 'MBR-67330068', 'PKG-005', 'new', 'Zahra Hidayat', 1799000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2024-11-03 12:00:00', '2026-06-29 19:19:49'),
(91, 'GYM-R0000082', 'MBR-17758382', 'PKG-001', 'new', 'Aditya Puspita', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2024-10-27 13:00:00', '2026-06-29 19:19:49'),
(92, 'GYM-R0000083', 'MBR-37060664', 'PKG-002', 'new', 'Aisyah Firmansyah', 379000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2024-10-20 14:00:00', '2026-06-29 19:19:49'),
(93, 'GYM-R0000084', 'MBR-63117339', 'PKG-003', 'new', 'Akbar Anggraini', 699000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2024-10-13 15:00:00', '2026-06-29 19:19:49'),
(94, 'GYM-R0000085', 'MBR-67754381', 'PKG-004', 'new', 'Anindya Setiawan', 999000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2024-10-06 16:00:00', '2026-06-29 19:19:49'),
(95, 'GYM-R0000086', 'MBR-50786871', 'PKG-005', 'new', 'Bagas Rahmawati', 1799000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2024-09-29 17:00:00', '2026-06-29 19:19:49'),
(96, 'GYM-R0000087', 'MBR-15601313', 'PKG-001', 'new', 'Bella Pratama', 199000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2024-09-22 18:00:00', '2026-06-29 19:19:49'),
(97, 'GYM-R0000088', 'MBR-82538800', 'PKG-002', 'new', 'Daffa Lestari', 379000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2024-09-15 08:00:00', '2026-06-29 19:19:49'),
(98, 'GYM-R0000089', 'MBR-30992422', 'PKG-003', 'new', 'Dewi Santoso', 699000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2024-09-08 09:00:00', '2026-06-29 19:19:49'),
(99, 'GYM-R0000090', 'MBR-25699523', 'PKG-004', 'new', 'Fajar Maharani', 999000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2024-09-01 10:00:00', '2026-06-29 19:19:49'),
(100, 'GYM-R0000091', 'MBR-96151253', 'PKG-005', 'new', 'Fitri Saputra', 1799000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2024-08-25 11:00:00', '2026-06-29 19:19:49'),
(101, 'GYM-R0000092', 'MBR-80788719', 'PKG-001', 'new', 'Galih Kartika', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2024-08-18 12:00:00', '2026-06-29 19:19:49'),
(102, 'GYM-R0000093', 'MBR-63513977', 'PKG-002', 'new', 'Intan Nugroho', 379000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2024-08-11 13:00:00', '2026-06-29 19:19:49'),
(103, 'GYM-R0000094', 'MBR-94272986', 'PKG-003', 'new', 'Kevin Wulandari', 699000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2024-08-04 14:00:00', '2026-06-29 19:19:49'),
(104, 'GYM-R0000095', 'MBR-39212492', 'PKG-004', 'new', 'Lestari Ramadhan', 999000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2024-07-28 15:00:00', '2026-06-29 19:19:49'),
(105, 'GYM-R0000096', 'MBR-81180278', 'PKG-005', 'new', 'Muhammad Permata', 1799000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Tahun', '2024-07-21 16:00:00', '2026-06-29 19:19:49'),
(106, 'GYM-R0000097', 'MBR-76788704', 'PKG-001', 'new', 'Nabila Kusuma', 199000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2024-07-14 17:00:00', '2026-06-29 19:19:49'),
(107, 'GYM-R0000098', 'MBR-53325041', 'PKG-002', 'new', 'Raka Hidayat', 379000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 2 Bulan', '2024-07-07 18:00:00', '2026-06-29 19:19:49'),
(108, 'GYM-R0000099', 'MBR-55496551', 'PKG-003', 'new', 'Salsabila Puspita', 699000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 4 Bulan', '2024-06-30 08:00:00', '2026-06-29 19:19:49'),
(109, 'GYM-R0000100', 'MBR-35109378', 'PKG-004', 'new', 'Yoga Firmansyah', 999000.00, 0.00, 'Cash', 'completed', 'Pendaftaran member baru - Paket 6 Bulan', '2026-05-24 09:00:00', '2026-06-29 19:19:49'),
(110, 'GYM-R0000131', 'MBR-90010001', 'PKG-001', 'new', 'Renata Alexandra', 199000.00, 0.00, 'Transfer', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2026-06-03 10:00:00', '2026-06-29 19:19:49'),
(111, 'GYM-R0000132', 'MBR-90010002', 'PKG-001', 'new', 'Ananda Vionarmanta', 199000.00, 0.00, 'QRIS', 'completed', 'Pendaftaran member baru - Paket 1 Bulan', '2026-06-06 10:00:00', '2026-06-29 19:19:49'),
(138, 'GYM-P0000004', 'MBR-21161094', 'PKG-002', 'member', 'Aisyah Lestari', 379000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 2 Bulan', '2026-06-26 14:00:00', '2026-06-29 19:19:49'),
(139, 'GYM-P0000005', 'MBR-50921893', 'PKG-003', 'member', 'Akbar Santoso', 699000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 4 Bulan', '2026-02-18 15:00:00', '2026-06-29 19:19:49'),
(140, 'GYM-P0000006', 'MBR-15500595', 'PKG-004', 'member', 'Anindya Maharani', 999000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 6 Bulan', '2026-03-20 16:00:00', '2026-06-29 19:19:49'),
(141, 'GYM-P0000007', 'MBR-29429897', 'PKG-005', 'member', 'Bagas Saputra', 1799000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 1 Tahun', '2025-09-27 17:00:00', '2026-06-29 19:19:49'),
(143, 'GYM-P0000009', 'MBR-12069006', 'PKG-002', 'member', 'Daffa Nugroho', 379000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 2 Bulan', '2026-04-15 10:00:00', '2026-06-29 19:19:49'),
(145, 'GYM-P0000011', 'MBR-82894411', 'PKG-004', 'member', 'Fajar Ramadhan', 999000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 6 Bulan', '2026-05-14 12:00:00', '2026-06-29 19:19:49'),
(146, 'GYM-P0000012', 'MBR-50960861', 'PKG-005', 'member', 'Fitri Permata', 1799000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 1 Tahun', '2025-11-21 13:00:00', '2026-06-29 19:19:49'),
(147, 'GYM-P0000013', 'MBR-13047655', 'PKG-001', 'member', 'Galih Kusuma', 199000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-05-11 14:00:00', '2026-06-29 19:19:49'),
(151, 'GYM-P0000017', 'MBR-94067582', 'PKG-005', 'member', 'Muhammad Anggraini', 1799000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 1 Tahun', '2025-06-06 18:00:00', '2026-06-29 19:19:49'),
(155, 'GYM-P0000021', 'MBR-84434568', 'PKG-004', 'member', 'Yoga Lestari', 999000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 6 Bulan', '2025-12-04 13:00:00', '2026-06-29 19:19:49'),
(156, 'GYM-P0000022', 'MBR-56259230', 'PKG-005', 'member', 'Zahra Santoso', 1799000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 1 Tahun', '2026-03-11 14:00:00', '2026-06-29 19:19:49'),
(159, 'GYM-P0000025', 'MBR-60465809', 'PKG-003', 'member', 'Akbar Kartika', 699000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 4 Bulan', '2026-01-29 17:00:00', '2026-06-29 19:19:49'),
(161, 'GYM-P0000027', 'MBR-27014589', 'PKG-005', 'member', 'Bagas Wulandari', 1799000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 1 Tahun', '2026-05-05 10:00:00', '2026-06-29 19:19:49'),
(163, 'GYM-P0000029', 'MBR-99585082', 'PKG-002', 'member', 'Daffa Permata', 379000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 2 Bulan', '2026-03-26 12:00:00', '2026-06-29 19:19:49'),
(164, 'GYM-P0000030', 'MBR-48911788', 'PKG-003', 'member', 'Dewi Kusuma', 699000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 4 Bulan', '2026-04-13 13:00:00', '2026-06-29 19:19:49'),
(165, 'GYM-P0000031', 'MBR-54205257', 'PKG-004', 'member', 'Fajar Hidayat', 999000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 6 Bulan', '2026-02-23 14:00:00', '2026-06-29 19:19:49'),
(166, 'GYM-P0000032', 'MBR-85973215', 'PKG-005', 'member', 'Fitri Puspita', 1799000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 1 Tahun', '2025-09-02 15:00:00', '2026-06-29 19:19:49'),
(167, 'GYM-P0000035', 'MBR-17758382', 'PKG-001', 'member', 'Aditya Puspita', 199000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-06-25 18:00:00', '2026-06-29 19:19:49'),
(168, 'GYM-P0000036', 'MBR-14355776', 'PKG-001', 'member', 'Lestari Santoso', 199000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-06-25 10:00:00', '2026-06-29 19:19:49'),
(169, 'GYM-P0000038', 'MBR-96018192', 'PKG-001', 'member', 'Aditya Pratama', 199000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-06-28 12:00:00', '2026-06-29 19:19:49'),
(170, 'GYM-P0000039', 'MBR-21161094', 'PKG-002', 'member', 'Aisyah Lestari', 379000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 2 Bulan', '2026-06-26 13:00:00', '2026-06-29 19:19:49'),
(171, 'GYM-P0000040', 'MBR-50921893', 'PKG-003', 'member', 'Akbar Santoso', 699000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 4 Bulan', '2026-06-24 14:00:00', '2026-06-29 19:19:49'),
(172, 'GYM-P0000041', 'MBR-15500595', 'PKG-004', 'member', 'Anindya Maharani', 999000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 6 Bulan', '2026-06-21 15:00:00', '2026-06-29 19:19:49'),
(173, 'GYM-P0000042', 'MBR-29429897', 'PKG-005', 'member', 'Bagas Saputra', 1799000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 1 Tahun', '2026-06-19 16:00:00', '2026-06-29 19:19:49'),
(174, 'GYM-P0000043', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 1 Bulan', '2025-10-30 17:00:00', '2026-06-29 19:19:49'),
(175, 'GYM-P0000044', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 1 Bulan', '2025-11-30 18:00:00', '2026-06-29 19:19:49'),
(176, 'GYM-P0000045', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 1 Bulan', '2025-12-30 10:00:00', '2026-06-29 19:19:49'),
(177, 'GYM-P0000046', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-01-30 11:00:00', '2026-06-29 19:19:49'),
(178, 'GYM-P0000047', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-02-28 12:00:00', '2026-06-29 19:19:49'),
(179, 'GYM-P0000048', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'QRIS', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-03-30 13:00:00', '2026-06-29 19:19:49'),
(180, 'GYM-P0000049', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'Cash', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-04-30 14:00:00', '2026-06-29 19:19:49'),
(181, 'GYM-P0000050', 'MBR-58310427', 'PKG-001', 'member', 'Sabrilia Melda', 199000.00, 0.00, 'Transfer', 'completed', 'Perpanjangan - Paket 1 Bulan', '2026-05-30 15:00:00', '2026-06-29 19:19:49');

-- --------------------------------------------------------

--
-- Table structure for table `login_logs`
--

CREATE TABLE `login_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `username_input` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('success','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `failure_reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logged_in_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `login_logs`
--

INSERT INTO `login_logs` (`id`, `user_id`, `username_input`, `status`, `ip_address`, `user_agent`, `failure_reason`, `logged_in_at`) VALUES
(1, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-17 23:47:42'),
(2, 1, 'admin', 'failed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'password salah', '2026-06-18 00:19:06'),
(3, 1, 'admin', 'failed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'password salah', '2026-06-18 00:19:23'),
(4, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-06-18 00:19:41'),
(5, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-18 05:28:15'),
(6, NULL, 'wewtry', 'failed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'username tidak ditemukan', '2026-06-18 05:48:49'),
(7, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', NULL, '2026-06-18 05:49:11'),
(8, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-18 06:13:45'),
(9, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-18 06:15:28'),
(10, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-18 06:38:07'),
(11, 1, 'admin', 'success', '192.168.1.112', 'Dart/3.11 (dart:io)', NULL, '2026-06-18 06:58:33'),
(12, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-19 22:58:03'),
(13, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-20 15:08:38'),
(14, 1, 'admin', 'success', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-21 10:54:54'),
(15, 1, 'admin', 'success', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-21 10:57:21'),
(16, 1, 'admin', 'success', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-21 10:57:39'),
(17, 1, 'admin', 'success', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-21 10:59:00'),
(18, 1, 'admin', 'success', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-21 10:59:53'),
(19, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-21 12:33:45'),
(20, 1, 'admin', 'success', '127.0.0.1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456', NULL, '2026-06-21 12:42:19'),
(21, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-21 13:49:16'),
(22, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-21 15:31:40'),
(23, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-23 02:25:28'),
(24, 1, 'admin', 'failed', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', 'password salah', '2026-06-23 03:17:44'),
(25, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-23 03:17:48'),
(26, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-23 21:11:15'),
(27, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-24 21:58:13'),
(28, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 04:07:01'),
(29, 1, 'admin', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 04:57:09'),
(30, 3, 'kasir', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 06:40:20'),
(31, 1, 'admin', 'success', '::1', 'curl/8.11.0', NULL, '2026-06-25 06:59:32'),
(32, 3, 'kasir', 'failed', '::1', 'curl/8.11.0', 'password salah', '2026-06-25 06:59:53'),
(33, 4, 'sabril', 'failed', '::1', 'curl/8.11.0', 'password salah', '2026-06-25 06:59:54'),
(34, 1, 'admin', 'success', '::1', 'curl/8.11.0', NULL, '2026-06-25 07:00:26'),
(35, 3, 'kasir', 'success', '::1', 'curl/8.11.0', NULL, '2026-06-25 07:00:26'),
(36, 3, 'kasir', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 07:39:48'),
(37, 3, 'kasir', 'success', '127.0.0.1', 'curl/8.11.0', NULL, '2026-06-25 07:57:12'),
(38, 3, 'kasir', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 08:15:04'),
(39, 3, 'kasir', 'success', '192.168.1.106', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 08:24:17'),
(40, 3, 'kasir', 'success', '::1', 'curl/8.11.0', NULL, '2026-06-25 08:33:03'),
(41, 3, 'kasir', 'failed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 'password salah', '2026-06-25 13:53:40'),
(42, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', NULL, '2026-06-25 13:53:52'),
(43, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 16:10:31'),
(44, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-25 16:31:07'),
(45, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-25 17:20:29'),
(46, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-25 17:30:06'),
(47, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-25 17:32:54'),
(48, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-25 17:33:14'),
(49, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-25 17:45:17'),
(50, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-25 17:51:23'),
(51, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 18:53:10'),
(52, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-25 18:55:20'),
(53, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-26 23:33:55'),
(54, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-27 00:56:26'),
(55, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-27 01:39:21'),
(56, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-27 01:39:52'),
(57, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-27 01:44:22'),
(58, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-27 02:11:59'),
(59, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-27 10:34:08'),
(60, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-27 10:42:45'),
(61, 3, 'kasir', 'failed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', 'password salah', '2026-06-27 10:50:43'),
(62, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-27 10:50:47'),
(63, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-27 11:04:44'),
(64, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.8655', NULL, '2026-06-27 11:22:33'),
(65, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-27 19:11:08'),
(66, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-27 20:30:08'),
(67, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-28 12:02:49'),
(68, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-28 18:26:13'),
(69, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-28 18:36:15'),
(70, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-28 19:08:56'),
(71, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-28 19:56:31'),
(72, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-28 20:12:14'),
(73, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 19:11:31'),
(74, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 21:24:27'),
(75, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 21:37:26'),
(76, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 21:47:12'),
(77, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 21:53:29'),
(78, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 22:00:40'),
(79, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 22:10:29'),
(80, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 22:13:22'),
(81, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 22:18:41'),
(82, 3, 'kasir', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 22:24:09'),
(83, 1, 'admin', 'success', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0', NULL, '2026-06-29 22:53:18');

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

CREATE TABLE `members` (
  `id` bigint UNSIGNED NOT NULL,
  `member_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` enum('Male','Female') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date NOT NULL,
  `package_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `initial_package_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registration_date` date NOT NULL,
  `membership_expiry_date` date NOT NULL,
  `total_visits` int UNSIGNED NOT NULL DEFAULT '0',
  `photo_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `members`
--

INSERT INTO `members` (`id`, `member_code`, `full_name`, `email`, `phone_number`, `address`, `gender`, `date_of_birth`, `package_code`, `initial_package_code`, `registration_date`, `membership_expiry_date`, `total_visits`, `photo_path`, `created_at`, `updated_at`) VALUES
(1, 'MBR-58310427', 'Sabrilia Melda', 'sabriliamelda@gmail.com', '081515004351', 'Jakarta', 'Female', '2004-09-09', 'PKG-001', 'PKG-001', '2025-09-30', '2026-06-30', 150, NULL, '2026-06-23 02:43:54', '2026-06-28 21:49:12'),
(2, 'MBR-96018192', 'Aditya Pratama', 'member002@example.com', '081500000002', 'Jakarta Selatan', 'Male', '1985-10-02', 'PKG-001', 'PKG-001', '2026-05-10', '2026-07-15', 74, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(3, 'MBR-21161094', 'Aisyah Lestari', 'member003@example.com', '081500000003', 'Jakarta Timur', 'Female', '1986-02-16', 'PKG-002', 'PKG-002', '2026-05-03', '2026-10-24', 111, NULL, '2026-06-23 02:43:54', '2026-06-28 19:02:15'),
(4, 'MBR-50921893', 'Akbar Santoso', 'member004@example.com', '081500000004', 'Jakarta Barat', 'Male', '1986-07-03', 'PKG-003', 'PKG-003', '2026-04-26', '2026-10-16', 148, NULL, '2026-06-23 02:43:54', '2026-06-28 19:02:15'),
(5, 'MBR-15500595', 'Anindya Maharani', 'member005@example.com', '081500000005', 'Jakarta Utara', 'Female', '1986-11-17', 'PKG-004', 'PKG-004', '2026-04-19', '2027-03-15', 185, NULL, '2026-06-23 02:43:54', '2026-06-28 19:02:15'),
(6, 'MBR-29429897', 'Bagas Saputra', 'member006@example.com', '081500000006', 'Jakarta Pusat', 'Male', '1987-04-03', 'PKG-005', 'PKG-005', '2026-04-12', '2027-09-27', 222, NULL, '2026-06-23 02:43:54', '2026-06-28 19:02:15'),
(7, 'MBR-11411615', 'Bella Kartika', 'member007@example.com', '081500000007', 'Tangerang', 'Female', '1987-08-18', 'PKG-001', 'PKG-001', '2026-04-05', '2026-09-08', 29, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(8, 'MBR-12069006', 'Daffa Nugroho', 'member008@example.com', '081500000008', 'Tangerang Selatan', 'Male', '1988-01-02', 'PKG-002', 'PKG-002', '2026-03-29', '2026-07-01', 66, NULL, '2026-06-23 02:43:54', '2026-06-28 19:05:54'),
(9, 'MBR-33879704', 'Dewi Wulandari', 'member009@example.com', '081500000009', 'Bekasi', 'Female', '1988-05-18', 'PKG-003', 'PKG-003', '2026-03-22', '2026-07-02', 103, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(10, 'MBR-82894411', 'Fajar Ramadhan', 'member010@example.com', '081500000010', 'Depok', 'Male', '1988-10-02', 'PKG-004', 'PKG-004', '2026-03-15', '2026-06-30', 140, NULL, '2026-06-23 02:43:54', '2026-06-28 19:05:54'),
(11, 'MBR-50960861', 'Fitri Permata', 'member011@example.com', '081500000011', 'Bogor', 'Female', '1989-02-16', 'PKG-005', 'PKG-005', '2026-03-08', '2026-07-01', 177, NULL, '2026-06-23 02:43:54', '2026-06-28 19:05:54'),
(12, 'MBR-13047655', 'Galih Kusuma', 'member012@example.com', '081500000012', 'Jakarta Selatan', 'Male', '1989-07-03', 'PKG-001', 'PKG-001', '2026-03-01', '2026-06-29', 214, NULL, '2026-06-23 02:43:54', '2026-06-28 19:05:54'),
(13, 'MBR-98420337', 'Intan Hidayat', 'member013@example.com', '081500000013', 'Jakarta Timur', 'Female', '1989-11-17', 'PKG-002', 'PKG-002', '2026-02-22', '2026-10-14', 21, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(14, 'MBR-54193362', 'Kevin Puspita', 'member014@example.com', '081500000014', 'Jakarta Barat', 'Male', '1990-04-03', 'PKG-003', 'PKG-003', '2026-02-15', '2026-08-26', 58, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(15, 'MBR-76485444', 'Lestari Firmansyah', 'member015@example.com', '081500000015', 'Jakarta Utara', 'Female', '1990-08-18', 'PKG-004', 'PKG-004', '2026-02-08', '2026-07-08', 95, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(16, 'MBR-94067582', 'Muhammad Anggraini', 'member016@example.com', '081500000016', 'Jakarta Pusat', 'Male', '1991-01-02', 'PKG-005', 'PKG-005', '2026-02-01', '2026-06-30', 132, NULL, '2026-06-23 02:43:54', '2026-06-28 19:05:54'),
(17, 'MBR-12061288', 'Nabila Setiawan', 'member017@example.com', '081500000017', 'Tangerang', 'Female', '1991-05-19', 'PKG-001', 'PKG-001', '2026-01-25', '2026-12-27', 169, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(18, 'MBR-33680249', 'Raka Rahmawati', 'member018@example.com', '081500000018', 'Tangerang Selatan', 'Male', '1991-10-03', 'PKG-002', 'PKG-002', '2026-01-18', '2026-12-08', 206, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(19, 'MBR-23204335', 'Salsabila Pratama', 'member019@example.com', '081500000019', 'Bekasi', 'Female', '1992-02-17', 'PKG-003', 'PKG-003', '2026-01-11', '2026-10-20', 13, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(20, 'MBR-84434568', 'Yoga Lestari', 'member020@example.com', '081500000020', 'Depok', 'Male', '1992-07-03', 'PKG-004', 'PKG-004', '2026-01-04', '2026-07-01', 50, NULL, '2026-06-23 02:43:54', '2026-06-28 19:05:54'),
(21, 'MBR-56259230', 'Zahra Santoso', 'member021@example.com', '081500000021', 'Bogor', 'Female', '1992-11-17', 'PKG-005', 'PKG-005', '2025-12-28', '2026-06-29', 87, NULL, '2026-06-23 02:43:54', '2026-06-28 19:05:54'),
(22, 'MBR-72268836', 'Aditya Maharani', 'member022@example.com', '081500000022', 'Jakarta Selatan', 'Male', '1993-04-03', 'PKG-001', 'PKG-001', '2025-12-21', '2026-01-20', 124, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(23, 'MBR-40746930', 'Aisyah Saputra', 'member023@example.com', '081500000023', 'Jakarta Timur', 'Female', '1993-08-18', 'PKG-002', 'PKG-002', '2025-12-14', '2026-02-12', 161, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(24, 'MBR-60465809', 'Akbar Kartika', 'member024@example.com', '081500000024', 'Jakarta Barat', 'Male', '1994-01-02', 'PKG-003', 'PKG-003', '2025-12-07', '2026-05-29', 198, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(25, 'MBR-66500231', 'Anindya Nugroho', 'member025@example.com', '081500000025', 'Jakarta Utara', 'Female', '1994-05-19', 'PKG-004', 'PKG-004', '2025-11-30', '2026-10-26', 5, NULL, '2026-06-23 02:43:54', '2026-06-29 21:56:58'),
(26, 'MBR-27014589', 'Bagas Wulandari', 'member026@example.com', '081500000026', 'Jakarta Pusat', 'Male', '1994-10-03', 'PKG-005', 'PKG-005', '2025-11-23', '2027-05-05', 42, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(27, 'MBR-74436139', 'Bella Ramadhan', 'member027@example.com', '081500000027', 'Tangerang', 'Female', '1995-02-17', 'PKG-001', 'PKG-001', '2025-11-16', '2025-12-16', 79, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(28, 'MBR-99585082', 'Daffa Permata', 'member028@example.com', '081500000028', 'Tangerang Selatan', 'Male', '1995-07-04', 'PKG-002', 'PKG-002', '2025-11-09', '2026-05-25', 116, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(29, 'MBR-48911788', 'Dewi Kusuma', 'member029@example.com', '081500000029', 'Bekasi', 'Female', '1995-11-18', 'PKG-003', 'PKG-003', '2025-11-02', '2026-08-11', 153, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(30, 'MBR-54205257', 'Fajar Hidayat', 'member030@example.com', '081500000030', 'Depok', 'Male', '1996-04-03', 'PKG-004', 'PKG-004', '2025-10-26', '2026-08-22', 190, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(31, 'MBR-85973215', 'Fitri Puspita', 'member031@example.com', '081500000031', 'Bogor', 'Female', '1996-08-18', 'PKG-005', 'PKG-005', '2025-10-19', '2026-09-02', 227, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(32, 'MBR-44897893', 'Galih Firmansyah', 'member032@example.com', '081500000032', 'Jakarta Selatan', 'Male', '1997-01-02', 'PKG-001', 'PKG-001', '2025-10-12', '2026-05-21', 34, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(33, 'MBR-72827763', 'Intan Anggraini', 'member033@example.com', '081500000033', 'Jakarta Timur', 'Female', '1997-05-19', 'PKG-002', 'PKG-002', '2025-10-05', '2026-09-24', 71, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(34, 'MBR-87861712', 'Kevin Setiawan', 'member034@example.com', '081500000034', 'Jakarta Barat', 'Male', '1997-10-03', 'PKG-003', 'PKG-003', '2025-09-28', '2026-10-05', 108, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(35, 'MBR-40686150', 'Lestari Rahmawati', 'member035@example.com', '081500000035', 'Jakarta Utara', 'Female', '1998-02-17', 'PKG-004', 'PKG-004', '2025-09-21', '2026-10-16', 145, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(36, 'MBR-55171708', 'Muhammad Pratama', 'member036@example.com', '081500000036', 'Jakarta Pusat', 'Male', '1998-07-04', 'PKG-005', 'PKG-005', '2025-09-14', '2026-05-17', 182, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(37, 'MBR-48891754', 'Nabila Lestari', 'member037@example.com', '081500000037', 'Tangerang', 'Female', '1998-11-18', 'PKG-001', 'PKG-001', '2025-09-07', '2026-11-07', 219, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(38, 'MBR-70264955', 'Raka Santoso', 'member038@example.com', '081500000038', 'Tangerang Selatan', 'Male', '1999-04-04', 'PKG-002', 'PKG-002', '2025-08-31', '2026-11-18', 26, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(39, 'MBR-78748525', 'Salsabila Maharani', 'member039@example.com', '081500000039', 'Bekasi', 'Female', '1999-08-19', 'PKG-003', 'PKG-003', '2025-08-24', '2026-11-29', 63, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(40, 'MBR-39233678', 'Yoga Saputra', 'member040@example.com', '081500000040', 'Depok', 'Male', '2000-01-03', 'PKG-004', 'PKG-004', '2025-08-17', '2026-05-13', 100, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(41, 'MBR-94058136', 'Zahra Kartika', 'member041@example.com', '081500000041', 'Bogor', 'Female', '2000-05-19', 'PKG-005', 'PKG-005', '2025-08-10', '2026-12-21', 137, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(42, 'MBR-17986978', 'Aditya Nugroho', 'member042@example.com', '081500000042', 'Jakarta Selatan', 'Male', '2000-10-03', 'PKG-001', 'PKG-001', '2025-08-03', '2025-09-02', 174, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(43, 'MBR-89722932', 'Aisyah Wulandari', 'member043@example.com', '081500000043', 'Jakarta Timur', 'Female', '2001-02-17', 'PKG-002', 'PKG-002', '2025-07-27', '2025-09-25', 211, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(44, 'MBR-91874455', 'Akbar Ramadhan', 'member044@example.com', '081500000044', 'Jakarta Barat', 'Male', '2001-07-04', 'PKG-003', 'PKG-003', '2025-07-20', '2026-05-09', 18, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(45, 'MBR-46690945', 'Anindya Permata', 'member045@example.com', '081500000045', 'Jakarta Utara', 'Female', '2001-11-18', 'PKG-004', 'PKG-004', '2025-07-13', '2026-01-09', 55, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(46, 'MBR-93027387', 'Bagas Kusuma', 'member046@example.com', '081500000046', 'Jakarta Pusat', 'Male', '2002-04-04', 'PKG-005', 'PKG-005', '2025-07-06', '2026-07-06', 92, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(47, 'MBR-17924525', 'Bella Hidayat', 'member047@example.com', '081500000047', 'Tangerang', 'Female', '2002-08-19', 'PKG-001', 'PKG-001', '2025-06-29', '2025-07-29', 129, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(48, 'MBR-39160764', 'Daffa Puspita', 'member048@example.com', '081500000048', 'Tangerang Selatan', 'Male', '2003-01-03', 'PKG-002', 'PKG-002', '2025-06-22', '2026-05-05', 166, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(49, 'MBR-26745258', 'Dewi Firmansyah', 'member049@example.com', '081500000049', 'Bekasi', 'Female', '2003-05-20', 'PKG-003', 'PKG-003', '2025-06-15', '2025-10-13', 203, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(50, 'MBR-11330127', 'Fajar Anggraini', 'member050@example.com', '081500000050', 'Depok', 'Male', '2003-10-04', 'PKG-004', 'PKG-004', '2025-06-08', '2025-12-05', 10, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(51, 'MBR-29348185', 'Fitri Setiawan', 'member051@example.com', '081500000051', 'Bogor', 'Female', '2004-02-18', 'PKG-005', 'PKG-005', '2025-06-01', '2026-06-01', 47, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(52, 'MBR-80354147', 'Galih Rahmawati', 'member052@example.com', '081500000052', 'Jakarta Selatan', 'Male', '2004-07-04', 'PKG-001', 'PKG-001', '2025-05-25', '2026-05-01', 84, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(53, 'MBR-25775221', 'Intan Pratama', 'member053@example.com', '081500000053', 'Jakarta Timur', 'Female', '2004-11-18', 'PKG-002', 'PKG-002', '2025-05-18', '2025-07-17', 121, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(54, 'MBR-29498966', 'Kevin Lestari', 'member054@example.com', '081500000054', 'Jakarta Barat', 'Male', '1985-04-09', 'PKG-003', 'PKG-003', '2025-05-11', '2025-09-08', 158, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(55, 'MBR-14355776', 'Lestari Santoso', 'member055@example.com', '081500000055', 'Jakarta Utara', 'Female', '1985-08-24', 'PKG-001', 'PKG-001', '2025-05-04', '2026-08-27', 195, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(56, 'MBR-33019770', 'Muhammad Maharani', 'member056@example.com', '081500000056', 'Jakarta Pusat', 'Male', '1986-01-08', 'PKG-005', 'PKG-005', '2025-04-27', '2026-04-27', 2, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(57, 'MBR-78448748', 'Nabila Saputra', 'member057@example.com', '081500000057', 'Tangerang', 'Female', '1986-05-25', 'PKG-001', 'PKG-001', '2025-04-20', '2026-08-19', 39, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(58, 'MBR-13739261', 'Raka Kartika', 'member058@example.com', '081500000058', 'Tangerang Selatan', 'Male', '1986-10-09', 'PKG-002', 'PKG-002', '2025-04-13', '2026-08-30', 76, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(59, 'MBR-54779499', 'Salsabila Nugroho', 'member059@example.com', '081500000059', 'Bekasi', 'Female', '1987-02-23', 'PKG-003', 'PKG-003', '2025-04-06', '2026-09-10', 113, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(60, 'MBR-90812684', 'Yoga Wulandari', 'member060@example.com', '081500000060', 'Depok', 'Male', '1987-07-10', 'PKG-004', 'PKG-004', '2025-03-30', '2026-04-23', 150, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(61, 'MBR-36153882', 'Zahra Ramadhan', 'member061@example.com', '081500000061', 'Bogor', 'Female', '1987-11-24', 'PKG-005', 'PKG-005', '2025-03-23', '2026-10-02', 187, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(62, 'MBR-53244320', 'Aditya Permata', 'member062@example.com', '081500000062', 'Jakarta Selatan', 'Male', '1988-04-09', 'PKG-001', 'PKG-001', '2025-03-16', '2026-10-13', 224, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(63, 'MBR-48205878', 'Aisyah Kusuma', 'member063@example.com', '081500000063', 'Jakarta Timur', 'Female', '1988-08-24', 'PKG-002', 'PKG-002', '2025-03-09', '2026-10-24', 31, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(64, 'MBR-35313685', 'Akbar Hidayat', 'member064@example.com', '081500000064', 'Jakarta Barat', 'Male', '1989-01-08', 'PKG-003', 'PKG-003', '2025-03-02', '2026-04-19', 68, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(65, 'MBR-15380611', 'Anindya Puspita', 'member065@example.com', '081500000065', 'Jakarta Utara', 'Female', '1989-05-25', 'PKG-004', 'PKG-004', '2025-02-23', '2026-11-15', 105, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(66, 'MBR-64813113', 'Bagas Firmansyah', 'member066@example.com', '081500000066', 'Jakarta Pusat', 'Male', '1989-10-09', 'PKG-005', 'PKG-005', '2025-02-16', '2026-11-26', 142, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(67, 'MBR-48202159', 'Bella Anggraini', 'member067@example.com', '081500000067', 'Tangerang', 'Female', '1990-02-23', 'PKG-001', 'PKG-001', '2025-02-09', '2026-12-07', 179, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(68, 'MBR-69683646', 'Daffa Setiawan', 'member068@example.com', '081500000068', 'Tangerang Selatan', 'Male', '1990-07-10', 'PKG-002', 'PKG-002', '2025-02-02', '2026-04-15', 216, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(69, 'MBR-84091432', 'Dewi Rahmawati', 'member069@example.com', '081500000069', 'Bekasi', 'Female', '1990-11-24', 'PKG-003', 'PKG-003', '2025-01-26', '2026-12-29', 23, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(70, 'MBR-61631437', 'Fajar Pratama', 'member070@example.com', '081500000070', 'Depok', 'Male', '1991-04-10', 'PKG-004', 'PKG-004', '2025-01-19', '2025-07-18', 60, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(71, 'MBR-66915931', 'Fitri Lestari', 'member071@example.com', '081500000071', 'Bogor', 'Female', '1991-08-25', 'PKG-005', 'PKG-005', '2025-01-12', '2026-01-12', 97, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(72, 'MBR-24825313', 'Galih Santoso', 'member072@example.com', '081500000072', 'Jakarta Selatan', 'Male', '1992-01-09', 'PKG-001', 'PKG-001', '2025-01-05', '2026-04-11', 134, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(73, 'MBR-79238647', 'Intan Maharani', 'member073@example.com', '081500000073', 'Jakarta Timur', 'Female', '1992-05-25', 'PKG-002', 'PKG-002', '2024-12-29', '2025-02-27', 171, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(74, 'MBR-61660500', 'Kevin Saputra', 'member074@example.com', '081500000074', 'Jakarta Barat', 'Male', '1992-10-09', 'PKG-003', 'PKG-003', '2024-12-22', '2025-04-21', 208, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(75, 'MBR-78517442', 'Lestari Kartika', 'member075@example.com', '081500000075', 'Jakarta Utara', 'Female', '1993-02-23', 'PKG-004', 'PKG-004', '2024-12-15', '2025-06-13', 15, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(76, 'MBR-94019320', 'Muhammad Nugroho', 'member076@example.com', '081500000076', 'Jakarta Pusat', 'Male', '1993-07-10', 'PKG-005', 'PKG-005', '2024-12-08', '2026-04-07', 52, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(77, 'MBR-23706862', 'Nabila Wulandari', 'member077@example.com', '081500000077', 'Tangerang', 'Female', '1993-11-24', 'PKG-001', 'PKG-001', '2024-12-01', '2024-12-31', 89, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(78, 'MBR-39314431', 'Raka Ramadhan', 'member078@example.com', '081500000078', 'Tangerang Selatan', 'Male', '1994-04-10', 'PKG-002', 'PKG-002', '2024-11-24', '2025-01-23', 126, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(79, 'MBR-22879081', 'Salsabila Permata', 'member079@example.com', '081500000079', 'Bekasi', 'Female', '1994-08-25', 'PKG-003', 'PKG-003', '2024-11-17', '2025-03-17', 163, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(80, 'MBR-49809794', 'Yoga Kusuma', 'member080@example.com', '081500000080', 'Depok', 'Male', '1995-01-09', 'PKG-004', 'PKG-004', '2024-11-10', '2026-04-03', 200, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(81, 'MBR-67330068', 'Zahra Hidayat', 'member081@example.com', '081500000081', 'Bogor', 'Female', '1995-05-26', 'PKG-005', 'PKG-005', '2024-11-03', '2025-11-03', 7, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(82, 'MBR-17758382', 'Aditya Puspita', 'member082@example.com', '081500000082', 'Jakarta Selatan', 'Male', '1995-10-10', 'PKG-001', 'PKG-001', '2024-10-27', '2026-08-24', 44, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(83, 'MBR-37060664', 'Aisyah Firmansyah', 'member083@example.com', '081500000083', 'Jakarta Timur', 'Female', '1996-02-24', 'PKG-002', 'PKG-002', '2024-10-20', '2026-08-05', 81, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(84, 'MBR-63117339', 'Akbar Anggraini', 'member084@example.com', '081500000084', 'Jakarta Barat', 'Male', '1996-07-10', 'PKG-003', 'PKG-003', '2024-10-13', '2026-03-30', 118, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(85, 'MBR-67754381', 'Anindya Setiawan', 'member085@example.com', '081500000085', 'Jakarta Utara', 'Female', '1996-11-24', 'PKG-004', 'PKG-004', '2024-10-06', '2026-08-27', 155, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(86, 'MBR-50786871', 'Bagas Rahmawati', 'member086@example.com', '081500000086', 'Jakarta Pusat', 'Male', '1997-04-10', 'PKG-005', 'PKG-005', '2024-09-29', '2026-09-07', 192, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(87, 'MBR-15601313', 'Bella Pratama', 'member087@example.com', '081500000087', 'Tangerang', 'Female', '1997-08-25', 'PKG-001', 'PKG-001', '2024-09-22', '2026-09-18', 229, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(88, 'MBR-82538800', 'Daffa Lestari', 'member088@example.com', '081500000088', 'Tangerang Selatan', 'Male', '1998-01-09', 'PKG-002', 'PKG-002', '2024-09-15', '2026-03-26', 36, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(89, 'MBR-30992422', 'Dewi Santoso', 'member089@example.com', '081500000089', 'Bekasi', 'Female', '1998-05-26', 'PKG-003', 'PKG-003', '2024-09-08', '2026-10-10', 73, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(90, 'MBR-25699523', 'Fajar Maharani', 'member090@example.com', '081500000090', 'Depok', 'Male', '1998-10-10', 'PKG-004', 'PKG-004', '2024-09-01', '2026-10-21', 110, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(91, 'MBR-96151253', 'Fitri Saputra', 'member091@example.com', '081500000091', 'Bogor', 'Female', '1999-02-24', 'PKG-005', 'PKG-005', '2024-08-25', '2026-11-01', 147, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(92, 'MBR-80788719', 'Galih Kartika', 'member092@example.com', '081500000092', 'Jakarta Selatan', 'Male', '1999-07-11', 'PKG-001', 'PKG-001', '2024-08-18', '2026-03-22', 184, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(93, 'MBR-63513977', 'Intan Nugroho', 'member093@example.com', '081500000093', 'Jakarta Timur', 'Female', '1999-11-25', 'PKG-002', 'PKG-002', '2024-08-11', '2026-11-23', 221, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(94, 'MBR-94272986', 'Kevin Wulandari', 'member094@example.com', '081500000094', 'Jakarta Barat', 'Male', '2000-04-10', 'PKG-003', 'PKG-003', '2024-08-04', '2026-12-04', 28, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(95, 'MBR-39212492', 'Lestari Ramadhan', 'member095@example.com', '081500000095', 'Jakarta Utara', 'Female', '2000-08-25', 'PKG-004', 'PKG-004', '2024-07-28', '2026-12-15', 65, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(96, 'MBR-81180278', 'Muhammad Permata', 'member096@example.com', '081500000096', 'Jakarta Pusat', 'Male', '2001-01-09', 'PKG-005', 'PKG-005', '2024-07-21', '2026-03-18', 102, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(97, 'MBR-76788704', 'Nabila Kusuma', 'member097@example.com', '081500000097', 'Tangerang', 'Female', '2001-05-26', 'PKG-001', 'PKG-001', '2024-07-14', '2024-08-13', 139, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(98, 'MBR-53325041', 'Raka Hidayat', 'member098@example.com', '081500000098', 'Tangerang Selatan', 'Male', '2001-10-10', 'PKG-002', 'PKG-002', '2024-07-07', '2024-09-05', 176, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(99, 'MBR-55496551', 'Salsabila Puspita', 'member099@example.com', '081500000099', 'Bekasi', 'Female', '2002-02-24', 'PKG-003', 'PKG-003', '2024-06-30', '2024-10-28', 213, NULL, '2026-06-23 02:43:54', '2026-06-29 21:58:03'),
(100, 'MBR-35109378', 'Yoga Firmansyah', 'member100@example.com', '081500000100', 'Depok', 'Male', '2002-07-11', 'PKG-004', 'PKG-004', '2026-05-24', '2026-03-14', 20, NULL, '2026-06-23 02:43:54', '2026-06-25 08:29:51'),
(131, 'MBR-90010001', 'Renata Alexandra', 'rntalxndr@gmail.com', '081200010001', 'Jakarta', 'Female', '2002-03-15', 'PKG-001', 'PKG-001', '2026-06-03', '2026-07-03', 20, NULL, '2026-06-28 21:28:22', '2026-06-29 21:41:10'),
(132, 'MBR-90010002', 'Ananda Vionarmanta', 'vionarmanta@gmail.com', '081200010002', 'Jakarta', 'Female', '2001-07-22', 'PKG-001', 'PKG-001', '2026-06-06', '2026-07-06', 22, NULL, '2026-06-28 21:28:22', '2026-06-29 21:41:10');

-- --------------------------------------------------------

--
-- Table structure for table `member_follow_ups`
--

CREATE TABLE `member_follow_ups` (
  `id` bigint UNSIGNED NOT NULL,
  `member_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `follow_up_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'renewal',
  `sent_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `member_follow_ups`
--

INSERT INTO `member_follow_ups` (`id`, `member_code`, `recipient_email`, `subject`, `follow_up_type`, `sent_at`, `created_at`) VALUES
(1, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Pengingat Perpanjangan Membership X-FIT', 'renewal', '2026-06-21 03:45:56', '2026-06-23 03:45:56'),
(2, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Pengingat Perpanjangan Membership X-FIT', 'renewal', '2026-06-23 03:59:25', '2026-06-23 03:59:25'),
(3, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Pengingat Perpanjangan Membership X-FIT', 'renewal', '2026-06-23 04:03:05', '2026-06-23 04:03:05'),
(4, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Pengingat Perpanjangan Membership X-FIT', 'renewal', '2026-06-23 04:08:05', '2026-06-23 04:08:05'),
(5, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Pengingat Perpanjangan Membership X-FIT - MBR-58310427', 'renewal', '2026-06-23 04:13:40', '2026-06-23 04:13:40'),
(6, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Voucher Makan Anda Sudah Aktif - X-FIT', 'voucher_active', '2026-06-28 12:02:25', '2026-06-28 12:02:25'),
(7, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Voucher Makan Anda Sudah Aktif - X-FIT', 'voucher_active', '2026-06-28 18:25:25', '2026-06-28 18:25:25'),
(8, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Voucher Makan Anda Sudah Aktif - X-FIT', 'voucher_active', '2026-06-28 19:49:25', '2026-06-28 19:49:25'),
(9, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Voucher Makan Anda Sudah Aktif - X-FIT', 'voucher_active', '2026-06-28 20:01:56', '2026-06-28 20:01:56'),
(10, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Voucher Makan 35% Sudah Aktif - X-FIT', 'voucher_active', '2026-06-28 21:21:23', '2026-06-28 21:21:23'),
(11, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Voucher Makan 35% Sudah Aktif - X-FIT', 'voucher_active', '2026-06-28 21:22:38', '2026-06-28 21:22:38'),
(12, 'MBR-58310427', 'sabriliamelda@gmail.com', 'Pengingat Perpanjangan Membership X-FIT - MBR-58310427', 'renewal', '2026-06-28 21:25:12', '2026-06-28 21:25:12'),
(13, 'MBR-90010002', 'vionarmanta@gmail.com', 'Pengingat Perpanjangan Membership X-FIT - MBR-90010002', 'renewal', '2026-06-28 21:29:45', '2026-06-28 21:29:45');

-- --------------------------------------------------------

--
-- Table structure for table `member_renewals`
--

CREATE TABLE `member_renewals` (
  `id` bigint UNSIGNED NOT NULL,
  `member_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `package_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `previous_expiry_date` date DEFAULT NULL,
  `new_expiry_date` date NOT NULL,
  `amount` decimal(12,2) UNSIGNED NOT NULL DEFAULT '0.00',
  `renewed_at` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `member_renewals`
--

INSERT INTO `member_renewals` (`id`, `member_code`, `package_code`, `previous_expiry_date`, `new_expiry_date`, `amount`, `renewed_at`, `created_at`) VALUES
(4, 'MBR-21161094', 'PKG-002', '2026-06-26', '2026-08-25', 379000.00, '2026-06-26', '2026-06-23 03:23:14'),
(5, 'MBR-50921893', 'PKG-003', '2026-02-18', '2026-06-18', 699000.00, '2026-02-18', '2026-06-23 03:23:14'),
(6, 'MBR-15500595', 'PKG-004', '2026-03-20', '2026-09-16', 999000.00, '2026-03-20', '2026-06-23 03:23:14'),
(7, 'MBR-29429897', 'PKG-005', '2025-09-27', '2026-09-27', 1799000.00, '2025-09-27', '2026-06-23 03:23:14'),
(9, 'MBR-12069006', 'PKG-002', '2026-04-15', '2026-06-14', 379000.00, '2026-04-15', '2026-06-23 03:23:14'),
(11, 'MBR-82894411', 'PKG-004', '2026-05-14', '2026-11-10', 999000.00, '2026-05-14', '2026-06-23 03:23:14'),
(12, 'MBR-50960861', 'PKG-005', '2025-11-21', '2026-11-21', 1799000.00, '2025-11-21', '2026-06-23 03:23:14'),
(13, 'MBR-13047655', 'PKG-001', '2026-05-11', '2026-06-10', 199000.00, '2026-05-11', '2026-06-23 03:23:14'),
(17, 'MBR-94067582', 'PKG-005', '2025-06-06', '2026-06-06', 1799000.00, '2025-06-06', '2026-06-23 03:23:14'),
(21, 'MBR-84434568', 'PKG-004', '2025-12-04', '2026-06-02', 999000.00, '2025-12-04', '2026-06-23 03:23:14'),
(22, 'MBR-56259230', 'PKG-005', '2026-03-11', '2027-03-11', 1799000.00, '2026-03-11', '2026-06-23 03:23:14'),
(25, 'MBR-60465809', 'PKG-003', '2026-01-29', '2026-05-29', 699000.00, '2026-01-29', '2026-06-23 03:23:14'),
(27, 'MBR-27014589', 'PKG-005', '2026-05-05', '2027-05-05', 1799000.00, '2026-05-05', '2026-06-23 03:23:14'),
(29, 'MBR-99585082', 'PKG-002', '2026-03-26', '2026-05-25', 379000.00, '2026-03-26', '2026-06-23 03:23:14'),
(30, 'MBR-48911788', 'PKG-003', '2026-04-13', '2026-08-11', 699000.00, '2026-04-13', '2026-06-23 03:23:14'),
(31, 'MBR-54205257', 'PKG-004', '2026-02-23', '2026-08-22', 999000.00, '2026-02-23', '2026-06-23 03:23:14'),
(32, 'MBR-85973215', 'PKG-005', '2025-09-02', '2026-09-02', 1799000.00, '2025-09-02', '2026-06-23 03:23:14'),
(35, 'MBR-17758382', 'PKG-001', '2026-07-25', '2026-08-24', 199000.00, '2026-06-25', '2026-06-25 08:15:33'),
(36, 'MBR-14355776', 'PKG-001', '2026-07-28', '2026-08-27', 199000.00, '2026-06-25', '2026-06-25 08:16:28'),
(38, 'MBR-96018192', 'PKG-001', '2026-08-14', '2026-09-13', 199000.00, '2026-06-28', '2026-06-28 19:02:14'),
(39, 'MBR-21161094', 'PKG-002', '2026-08-25', '2026-10-24', 379000.00, '2026-06-26', '2026-06-28 19:02:15'),
(40, 'MBR-50921893', 'PKG-003', '2026-06-18', '2026-10-16', 699000.00, '2026-06-24', '2026-06-28 19:02:15'),
(41, 'MBR-15500595', 'PKG-004', '2026-09-16', '2027-03-15', 999000.00, '2026-06-21', '2026-06-28 19:02:15'),
(42, 'MBR-29429897', 'PKG-005', '2026-09-27', '2027-09-27', 1799000.00, '2026-06-19', '2026-06-28 19:02:15'),
(43, 'MBR-58310427', 'PKG-001', '2025-10-30', '2025-11-30', 199000.00, '2025-10-30', '2026-06-28 21:49:12'),
(44, 'MBR-58310427', 'PKG-001', '2025-11-30', '2025-12-30', 199000.00, '2025-11-30', '2026-06-28 21:49:12'),
(45, 'MBR-58310427', 'PKG-001', '2025-12-30', '2026-01-30', 199000.00, '2025-12-30', '2026-06-28 21:49:12'),
(46, 'MBR-58310427', 'PKG-001', '2026-01-30', '2026-02-28', 199000.00, '2026-01-30', '2026-06-28 21:49:12'),
(47, 'MBR-58310427', 'PKG-001', '2026-02-28', '2026-03-30', 199000.00, '2026-02-28', '2026-06-28 21:49:12'),
(48, 'MBR-58310427', 'PKG-001', '2026-03-30', '2026-04-30', 199000.00, '2026-03-30', '2026-06-28 21:49:12'),
(49, 'MBR-58310427', 'PKG-001', '2026-04-30', '2026-05-30', 199000.00, '2026-04-30', '2026-06-28 21:49:12'),
(50, 'MBR-58310427', 'PKG-001', '2026-05-30', '2026-06-30', 199000.00, '2026-05-30', '2026-06-28 21:49:12');

-- --------------------------------------------------------

--
-- Stand-in structure for view `member_status`
-- (See below for the actual view)
--
CREATE TABLE `member_status` (
`id` bigint unsigned
,`member_code` varchar(12)
,`full_name` varchar(100)
,`email` varchar(150)
,`phone_number` varchar(20)
,`address` varchar(255)
,`gender` enum('Male','Female')
,`date_of_birth` date
,`package_code` varchar(20)
,`registration_date` date
,`membership_expiry_date` date
,`photo_path` varchar(255)
,`created_at` datetime
,`updated_at` datetime
,`status` varchar(18)
);

-- --------------------------------------------------------

--
-- Table structure for table `member_vouchers`
--

CREATE TABLE `member_vouchers` (
  `id` bigint UNSIGNED NOT NULL,
  `member_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `visit_milestone` int UNSIGNED NOT NULL,
  `voucher_percent` tinyint UNSIGNED NOT NULL,
  `activated_at` date NOT NULL,
  `expires_at` date NOT NULL,
  `used_at` date DEFAULT NULL,
  `active_notified_at` datetime DEFAULT NULL,
  `expiry_notified_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `member_vouchers`
--

INSERT INTO `member_vouchers` (`id`, `member_code`, `visit_milestone`, `voucher_percent`, `activated_at`, `expires_at`, `used_at`, `active_notified_at`, `expiry_notified_at`, `created_at`) VALUES
(3, 'MBR-96018192', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(4, 'MBR-21161094', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(5, 'MBR-21161094', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(6, 'MBR-50921893', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(7, 'MBR-50921893', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(8, 'MBR-15500595', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(9, 'MBR-15500595', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(10, 'MBR-15500595', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(11, 'MBR-29429897', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(12, 'MBR-29429897', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(13, 'MBR-29429897', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(14, 'MBR-29429897', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(15, 'MBR-12069006', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(16, 'MBR-33879704', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(17, 'MBR-33879704', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(18, 'MBR-82894411', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(19, 'MBR-82894411', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(20, 'MBR-50960861', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(21, 'MBR-50960861', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(22, 'MBR-50960861', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(23, 'MBR-13047655', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(24, 'MBR-13047655', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(25, 'MBR-13047655', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(26, 'MBR-13047655', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(27, 'MBR-54193362', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(28, 'MBR-76485444', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(29, 'MBR-94067582', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(30, 'MBR-94067582', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(31, 'MBR-12061288', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(32, 'MBR-12061288', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(33, 'MBR-12061288', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(34, 'MBR-33680249', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(35, 'MBR-33680249', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(36, 'MBR-33680249', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(37, 'MBR-33680249', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(38, 'MBR-84434568', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(39, 'MBR-56259230', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(40, 'MBR-72268836', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(41, 'MBR-72268836', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(42, 'MBR-40746930', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(43, 'MBR-40746930', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(44, 'MBR-40746930', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(45, 'MBR-60465809', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(46, 'MBR-60465809', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(47, 'MBR-60465809', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(48, 'MBR-74436139', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(49, 'MBR-99585082', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(50, 'MBR-99585082', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(51, 'MBR-48911788', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(52, 'MBR-48911788', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(53, 'MBR-48911788', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(54, 'MBR-54205257', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(55, 'MBR-54205257', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(56, 'MBR-54205257', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(57, 'MBR-85973215', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(58, 'MBR-85973215', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(59, 'MBR-85973215', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(60, 'MBR-85973215', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(61, 'MBR-72827763', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(62, 'MBR-87861712', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(63, 'MBR-87861712', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(64, 'MBR-40686150', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(65, 'MBR-40686150', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(66, 'MBR-55171708', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(67, 'MBR-55171708', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(68, 'MBR-55171708', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(69, 'MBR-48891754', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(70, 'MBR-48891754', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(71, 'MBR-48891754', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(72, 'MBR-48891754', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(73, 'MBR-78748525', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(74, 'MBR-39233678', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(75, 'MBR-39233678', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(76, 'MBR-94058136', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(77, 'MBR-94058136', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(78, 'MBR-17986978', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(79, 'MBR-17986978', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(80, 'MBR-17986978', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(81, 'MBR-89722932', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(82, 'MBR-89722932', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(83, 'MBR-89722932', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(84, 'MBR-89722932', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(85, 'MBR-46690945', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(86, 'MBR-93027387', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(87, 'MBR-17924525', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(88, 'MBR-17924525', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(89, 'MBR-39160764', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(90, 'MBR-39160764', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(91, 'MBR-39160764', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(92, 'MBR-26745258', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(93, 'MBR-26745258', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(94, 'MBR-26745258', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(95, 'MBR-26745258', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(96, 'MBR-80354147', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(97, 'MBR-25775221', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(98, 'MBR-25775221', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(99, 'MBR-29498966', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(100, 'MBR-29498966', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(101, 'MBR-29498966', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(102, 'MBR-14355776', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(103, 'MBR-14355776', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(104, 'MBR-14355776', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(105, 'MBR-13739261', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(106, 'MBR-54779499', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(107, 'MBR-54779499', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(108, 'MBR-90812684', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(109, 'MBR-90812684', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(110, 'MBR-90812684', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(111, 'MBR-36153882', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(112, 'MBR-36153882', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(113, 'MBR-36153882', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(114, 'MBR-53244320', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(115, 'MBR-53244320', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(116, 'MBR-53244320', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(117, 'MBR-53244320', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(118, 'MBR-35313685', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(119, 'MBR-15380611', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(120, 'MBR-15380611', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(121, 'MBR-64813113', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(122, 'MBR-64813113', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(123, 'MBR-48202159', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(124, 'MBR-48202159', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(125, 'MBR-48202159', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(126, 'MBR-69683646', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(127, 'MBR-69683646', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(128, 'MBR-69683646', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(129, 'MBR-69683646', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(130, 'MBR-61631437', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(131, 'MBR-66915931', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(132, 'MBR-24825313', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(133, 'MBR-24825313', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(134, 'MBR-79238647', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(135, 'MBR-79238647', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(136, 'MBR-79238647', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(137, 'MBR-61660500', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(138, 'MBR-61660500', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(139, 'MBR-61660500', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(140, 'MBR-61660500', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(141, 'MBR-94019320', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(142, 'MBR-23706862', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(143, 'MBR-39314431', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(144, 'MBR-39314431', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(145, 'MBR-22879081', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(146, 'MBR-22879081', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(147, 'MBR-22879081', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(148, 'MBR-49809794', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(149, 'MBR-49809794', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(150, 'MBR-49809794', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(151, 'MBR-49809794', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(152, 'MBR-37060664', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(153, 'MBR-63117339', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(154, 'MBR-63117339', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(155, 'MBR-67754381', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(156, 'MBR-67754381', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(157, 'MBR-67754381', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(158, 'MBR-50786871', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(159, 'MBR-50786871', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(160, 'MBR-50786871', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(161, 'MBR-15601313', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(162, 'MBR-15601313', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(163, 'MBR-15601313', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(164, 'MBR-15601313', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(165, 'MBR-30992422', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(166, 'MBR-25699523', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(167, 'MBR-25699523', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(168, 'MBR-96151253', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(169, 'MBR-96151253', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(170, 'MBR-80788719', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(171, 'MBR-80788719', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(172, 'MBR-80788719', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(173, 'MBR-63513977', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(174, 'MBR-63513977', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(175, 'MBR-63513977', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(176, 'MBR-63513977', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(177, 'MBR-39212492', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(178, 'MBR-81180278', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(179, 'MBR-81180278', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(180, 'MBR-76788704', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(181, 'MBR-76788704', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(182, 'MBR-53325041', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(183, 'MBR-53325041', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(184, 'MBR-53325041', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(185, 'MBR-55496551', 200, 45, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(186, 'MBR-55496551', 150, 35, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(187, 'MBR-55496551', 100, 25, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(188, 'MBR-55496551', 50, 10, '2026-06-28', '2026-07-28', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(256, 'MBR-58310427', 50, 10, '2026-06-14', '2026-07-14', '2026-06-16', '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(257, 'MBR-58310427', 100, 25, '2026-05-19', '2026-06-18', NULL, '2026-06-28 11:13:27', '2026-06-28 11:13:27', '2026-06-28 11:13:27'),
(258, 'MBR-58310427', 150, 35, '2026-06-23', '2026-07-23', NULL, '2026-06-28 20:01:51', '2026-06-28 11:13:27', '2026-06-28 11:13:27');

-- --------------------------------------------------------

--
-- Table structure for table `member_voucher_redemptions`
--

CREATE TABLE `member_voucher_redemptions` (
  `id` bigint UNSIGNED NOT NULL,
  `member_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `voucher_percent` tinyint UNSIGNED NOT NULL,
  `visit_milestone` int UNSIGNED NOT NULL,
  `used_at` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `member_voucher_redemptions`
--

INSERT INTO `member_voucher_redemptions` (`id`, `member_code`, `voucher_percent`, `visit_milestone`, `used_at`, `created_at`) VALUES
(1, 'MBR-58310427', 30, 50, '2026-06-11', '2026-06-23 03:19:55');

-- --------------------------------------------------------

--
-- Table structure for table `payment_status`
--

CREATE TABLE `payment_status` (
  `order_id` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `transaction_status` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fraud_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `paid` tinyint(1) NOT NULL DEFAULT '0',
  `gross_amount` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `payment_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','kasir') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `must_change_password` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `role`, `is_active`, `must_change_password`, `created_by`, `last_login_at`, `password_changed_at`, `created_at`, `updated_at`) VALUES
(1, 'admin', '$2y$12$JnOPW6t.MxWhCpyFRaU8i.z.qgt0ed1vhtYXi0dt3bSazZeBhfXmW', 'Administrator', 'admin', 1, 1, NULL, '2026-06-29 22:53:18', NULL, '2026-06-17 22:35:58', '2026-06-29 22:53:18'),
(2, 'sabrilia kasir', '$2a$10$Alj4KJUyTvEqaecUFYPyneTiJitM3BLE49vWCe7Htng/DjcVZtTte', 'Sabrilia', 'kasir', 1, 1, 1, NULL, '2026-06-18 06:41:39', '2026-06-18 06:22:05', '2026-06-18 06:41:39'),
(3, 'kasir', '$2a$10$E2sLvPqfdVMdbAhwctb92eqnBUR4nLoWkSxsLqgseV29SfanAbOKq', 'Sabrilia Melda', 'kasir', 1, 1, 1, '2026-06-29 22:24:09', '2026-06-25 07:00:26', '2026-06-25 06:32:59', '2026-06-29 22:24:09'),
(4, 'sabril', '$2a$10$N6glkN3aymCc6rnChCtfkekcn2Od5w2qy0AB/OKNMdJ386WMv/fYK', 'Sab', 'kasir', 1, 1, 1, NULL, NULL, '2026-06-25 06:34:30', '2026-06-25 06:34:30');

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `trg_users_protect_creator` BEFORE UPDATE ON `users` FOR EACH ROW BEGIN
  IF NOT (NEW.created_by <=> OLD.created_by) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'created_by tidak boleh diubah';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_users_validate_creator` BEFORE INSERT ON `users` FOR EACH ROW BEGIN
  IF NEW.created_by IS NULL THEN
    IF NEW.role <> 'admin' OR EXISTS (SELECT 1 FROM users LIMIT 1) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hanya admin pertama yang boleh dibuat tanpa created_by';
    END IF;
  ELSE
    IF NOT EXISTS (
      SELECT 1
      FROM users
      WHERE id = NEW.created_by
        AND role = 'admin'
        AND is_active = 1
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Akun baru hanya boleh dibuat oleh admin aktif';
    END IF;
  END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_attendance_member_day` (`member_code`,`attendance_date`),
  ADD KEY `idx_attendance_date` (`attendance_date`);

--
-- Indexes for table `food_beverage_items`
--
ALTER TABLE `food_beverage_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_food_beverage_items_item_id` (`item_id`),
  ADD KEY `idx_food_beverage_items_category` (`category`),
  ADD KEY `idx_food_beverage_items_active` (`is_active`);

--
-- Indexes for table `food_beverage_transactions`
--
ALTER TABLE `food_beverage_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_fnb_tx_code` (`transaction_code`),
  ADD KEY `idx_fnb_tx_date` (`transaction_date`),
  ADD KEY `idx_fnb_tx_member` (`member_code`);

--
-- Indexes for table `gym_packages`
--
ALTER TABLE `gym_packages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_gym_packages_code` (`package_code`),
  ADD KEY `idx_gym_packages_type` (`package_type`),
  ADD KEY `idx_gym_packages_active` (`is_active`);

--
-- Indexes for table `gym_transactions`
--
ALTER TABLE `gym_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_gym_transactions_code` (`transaction_code`),
  ADD KEY `idx_gym_transactions_member` (`member_code`),
  ADD KEY `idx_gym_transactions_date` (`transaction_date`),
  ADD KEY `fk_gym_transactions_package` (`package_code`);

--
-- Indexes for table `login_logs`
--
ALTER TABLE `login_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_login_logs_user` (`user_id`),
  ADD KEY `idx_login_logs_status` (`status`),
  ADD KEY `idx_login_logs_date` (`logged_in_at`);

--
-- Indexes for table `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_members_code` (`member_code`),
  ADD UNIQUE KEY `uq_members_email` (`email`),
  ADD KEY `idx_members_name` (`full_name`),
  ADD KEY `idx_members_phone` (`phone_number`),
  ADD KEY `idx_members_package` (`package_code`),
  ADD KEY `idx_members_expiry` (`membership_expiry_date`);

--
-- Indexes for table `member_follow_ups`
--
ALTER TABLE `member_follow_ups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_member_follow_ups_member` (`member_code`),
  ADD KEY `idx_member_follow_ups_sent` (`sent_at`);

--
-- Indexes for table `member_renewals`
--
ALTER TABLE `member_renewals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_member_renewals` (`member_code`,`new_expiry_date`),
  ADD KEY `idx_member_renewals_member` (`member_code`),
  ADD KEY `idx_member_renewals_date` (`renewed_at`),
  ADD KEY `fk_member_renewals_package` (`package_code`);

--
-- Indexes for table `member_vouchers`
--
ALTER TABLE `member_vouchers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_member_voucher` (`member_code`,`visit_milestone`),
  ADD KEY `idx_member_vouchers_member` (`member_code`);

--
-- Indexes for table `member_voucher_redemptions`
--
ALTER TABLE `member_voucher_redemptions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_member_voucher_milestone` (`member_code`,`visit_milestone`),
  ADD KEY `idx_member_voucher_member` (`member_code`);

--
-- Indexes for table `payment_status`
--
ALTER TABLE `payment_status`
  ADD PRIMARY KEY (`order_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_username` (`username`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_is_active` (`is_active`),
  ADD KEY `idx_users_created_by` (`created_by`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `food_beverage_items`
--
ALTER TABLE `food_beverage_items`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT for table `food_beverage_transactions`
--
ALTER TABLE `food_beverage_transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=202;

--
-- AUTO_INCREMENT for table `gym_packages`
--
ALTER TABLE `gym_packages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `gym_transactions`
--
ALTER TABLE `gym_transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=200;

--
-- AUTO_INCREMENT for table `login_logs`
--
ALTER TABLE `login_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;

--
-- AUTO_INCREMENT for table `members`
--
ALTER TABLE `members`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `member_follow_ups`
--
ALTER TABLE `member_follow_ups`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `member_renewals`
--
ALTER TABLE `member_renewals`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `member_vouchers`
--
ALTER TABLE `member_vouchers`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=259;

--
-- AUTO_INCREMENT for table `member_voucher_redemptions`
--
ALTER TABLE `member_voucher_redemptions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

-- --------------------------------------------------------

--
-- Structure for view `member_status`
--
DROP TABLE IF EXISTS `member_status`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `member_status`  AS SELECT `m`.`id` AS `id`, `m`.`member_code` AS `member_code`, `m`.`full_name` AS `full_name`, `m`.`email` AS `email`, `m`.`phone_number` AS `phone_number`, `m`.`address` AS `address`, `m`.`gender` AS `gender`, `m`.`date_of_birth` AS `date_of_birth`, `m`.`package_code` AS `package_code`, `m`.`registration_date` AS `registration_date`, `m`.`membership_expiry_date` AS `membership_expiry_date`, `m`.`photo_path` AS `photo_path`, `m`.`created_at` AS `created_at`, `m`.`updated_at` AS `updated_at`, (case when (`m`.`membership_expiry_date` < curdate()) then 'Kadaluwarsa' when (`m`.`membership_expiry_date` <= (curdate() + interval 7 day)) then 'Perlu Perpanjangan' else 'Aktif' end) AS `status` FROM `members` AS `m` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `gym_transactions`
--
ALTER TABLE `gym_transactions`
  ADD CONSTRAINT `fk_gym_transactions_package` FOREIGN KEY (`package_code`) REFERENCES `gym_packages` (`package_code`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `login_logs`
--
ALTER TABLE `login_logs`
  ADD CONSTRAINT `fk_login_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `members`
--
ALTER TABLE `members`
  ADD CONSTRAINT `fk_members_package` FOREIGN KEY (`package_code`) REFERENCES `gym_packages` (`package_code`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `member_follow_ups`
--
ALTER TABLE `member_follow_ups`
  ADD CONSTRAINT `fk_member_follow_ups_member` FOREIGN KEY (`member_code`) REFERENCES `members` (`member_code`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `member_renewals`
--
ALTER TABLE `member_renewals`
  ADD CONSTRAINT `fk_member_renewals_member` FOREIGN KEY (`member_code`) REFERENCES `members` (`member_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_member_renewals_package` FOREIGN KEY (`package_code`) REFERENCES `gym_packages` (`package_code`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `member_vouchers`
--
ALTER TABLE `member_vouchers`
  ADD CONSTRAINT `fk_member_vouchers_member` FOREIGN KEY (`member_code`) REFERENCES `members` (`member_code`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `member_voucher_redemptions`
--
ALTER TABLE `member_voucher_redemptions`
  ADD CONSTRAINT `fk_member_voucher_member` FOREIGN KEY (`member_code`) REFERENCES `members` (`member_code`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
