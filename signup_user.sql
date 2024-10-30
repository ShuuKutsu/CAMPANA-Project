-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 30, 2024 at 12:26 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `signup_user`
--

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `created_at`) VALUES
(1, 'demo1', '$2y$10$hkPACIOWQDN97jchbPZii.GFZYQXbDEdmLie7U6v16AoviaE7khEC', '2024-10-29 11:39:31'),
(2, 'shuukutsu', '$2y$10$AZcNzmjMpI9xP8QGi62FpOCp2mdiEBOodUzzMBvXH42WyK/KBJSEG', '2024-10-29 12:08:45'),
(3, 'a', '$2y$10$E4OF7krsBUxs5.KqgtMWdubXTYy4IbWSQ6Q5BvXVv2KhQClI/yeO2', '2024-10-30 08:33:16');

-- --------------------------------------------------------

--
-- Table structure for table `weather_table`
--

CREATE TABLE `weather_table` (
  `id` int(11) NOT NULL,
  `humidity` float(5,1) DEFAULT NULL,
  `amount_of_rain` float(5,1) DEFAULT NULL,
  `waterlevel` float(5,1) DEFAULT NULL,
  `windspeed` float(5,1) DEFAULT NULL,
  `temperature` float(5,1) DEFAULT NULL,
  `datetime` datetime DEFAULT NULL,
  `flood_risk` varchar(50) DEFAULT NULL,
  `chance_of_rain` varchar(50) DEFAULT NULL,
  `storm_signal` varchar(50) DEFAULT NULL,
  `temperature_desc` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `weather_table`
--

INSERT INTO `weather_table` (`id`, `humidity`, `amount_of_rain`, `waterlevel`, `windspeed`, `temperature`, `datetime`, `flood_risk`, `chance_of_rain`, `storm_signal`, `temperature_desc`) VALUES
(1, 50.0, 0.0, 0.0, 43.1, 25.0, '2024-10-05 18:07:27', 'none', 'Moderate C', 'Signal #1', 'Hot');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `weather_table`
--
ALTER TABLE `weather_table`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `weather_table`
--
ALTER TABLE `weather_table`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
