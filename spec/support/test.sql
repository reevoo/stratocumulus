DROP DATABASE IF EXISTS `stratocumulus_test`;
CREATE DATABASE `stratocumulus_test`;
USE `stratocumulus_test`;
DROP TABLE IF EXISTS `widgets`;
CREATE TABLE `widgets` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(256) DEFAULT NULL,
  `leavers` int(11) DEFAULT NULL,
  `pivots` int(11) DEFAULT NULL,
  `fulcrums` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
LOCK TABLES `widgets` WRITE;
INSERT INTO `widgets` VALUES (1,'Foo',3,1,2),(2,'Bar',2,2,0),(3,'Baz',5,6,4),(4,'Qux',4,5,6),(5,'Quux',8,5,4),(6,'Corge',8,2,7),(7,'Grault',7,3,4),(8,'Garply',1,2,3),(9,'Waldo',0,0,0),(10,'Fred',1,1,1),(11,'Plugh',8,5,3),(12,'Xyzzy',3,3,3),(13,'Thud',1,2,3);
UNLOCK TABLES;
