CREATE TABLE `rex_goldrush` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) DEFAULT NULL,
    `owner` varchar(50) DEFAULT NULL,
    `properties` text NOT NULL,
    `propid` int(11) NOT NULL,
    `proptype` varchar(50) DEFAULT NULL,
    `smallnugget` int(3) NOT NULL DEFAULT 0,
    `mediumnugget` int(3) NOT NULL DEFAULT 0,
    `largenugget` int(3) NOT NULL DEFAULT 0,
    `paydirt` int(3) NOT NULL DEFAULT 0,
    `water` int(3) NOT NULL DEFAULT 0,
    `quality` int(3) NOT NULL DEFAULT 100,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
