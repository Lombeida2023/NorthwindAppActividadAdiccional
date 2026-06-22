INSERT INTO customers (customer_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax) VALUES
('VINET','Vins et alcools Chevalier','Paul Henriot','Accounting Manager','59 rue de l''Abbaye','Reims',NULL,'51100','France','26.47.15.10','26.47.15.11'),
('TOMSP','Toms Spezialitäten','Karin Josephs','Marketing Manager','Luisenstr. 48','Münster',NULL,'44087','Germany','0251-031259','0251-035695'),
('HANAR','Hanari Carnes','Mario Pontes','Accounting Manager','Rua do Paço, 67','Rio de Janeiro','RJ','05454-876','Brazil','(21) 555-0091','(21) 555-8765'),
('VICTE','Victuailles en stock','Mary Saveley','Sales Agent','2, rue du Commerce','Lyon',NULL,'69004','France','78.32.54.86','78.32.54.87'),
('SUPRD','Suprêmes délices','Pascale Cartrain','Accounting Manager','Boulevard Tirou, 255','Charleroi',NULL,'B-6000','Belgium','(071) 23 67 22 20','(071) 23 67 22 21'),
('RICSU','Richter Supermarkt','Michael Holz','Sales Manager','Grenzacherweg 237','Genève',NULL,'1203','Switzerland','0897-034214',NULL),
('WELLI','Wellington Importadora','Paula Parente','Sales Manager','Rua do Mercado, 12','Resende','SP','08737-363','Brazil','(14) 555-8122',NULL),
('HILAA','HILARION-Abastos','Carlos Hernandez','Sales Representative','Carrera 22 con Ave. Carlos Soublette #8-35','San Cristobal','Tachira','5022','Venezuela','(5) 555-1340','(5) 555-1948'),
('OTTIK','Ottilies Kaseladen','Henriette Pfalzheim','Owner','Mehrheimerstr. 369','Koln',NULL,'50739','Germany','0221-0644327','0221-0765721'),
('QUEDE','Que Delicia','Bernardo Batista','Accounting Manager','Rua da Panificadora, 12','Rio de Janeiro','RJ','02389-673','Brazil','(21) 555-4252','(21) 555-4545'),
('RATTC','Rattlesnake Canyon Grocery','Paula Wilson','Assistant Sales Representative','2817 Milton Dr.','Albuquerque','NM','87110','USA','(505) 555-5939','(505) 555-3620'),
('FOLKO','Folk och fa HB','Maria Larsson','Owner','Akergatan 24','Bracke',NULL,'S-844 67','Sweden','0695-34 67 21',NULL),
('WARTH','Wartian Herkku','Pirkko Koskitalo','Accounting Manager','Torikatu 38','Oulu',NULL,'90110','Finland','981-443655','981-443655'),
('FRANK','Frankenversand','Peter Franken','Marketing Manager','Berliner Platz 43','Munchen',NULL,'80805','Germany','089-0877310','089-0877451')
ON CONFLICT DO NOTHING;

INSERT INTO orders (order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country) VALUES
(10248,'VINET',5,'1996-07-04','1996-08-01','1996-07-16',3,32.38,'Vins et alcools Chevalier','59 rue de l''Abbaye','Reims',NULL,'51100','France'),
(10249,'TOMSP',6,'1996-07-05','1996-08-16','1996-07-10',1,11.61,'Toms Spezialitaten','Luisenstr. 48','Munster',NULL,'44087','Germany'),
(10250,'HANAR',4,'1996-07-08','1996-08-05','1996-07-12',2,65.83,'Hanari Carnes','Rua do Paco, 67','Rio de Janeiro','RJ','05454-876','Brazil'),
(10251,'VICTE',3,'1996-07-08','1996-08-05','1996-07-15',1,41.34,'Victuailles en stock','2, rue du Commerce','Lyon',NULL,'69004','France'),
(10252,'SUPRD',4,'1996-07-09','1996-08-06','1996-07-11',2,51.30,'Supremes delices','Boulevard Tirou, 255','Charleroi',NULL,'B-6000','Belgium'),
(10253,'HANAR',3,'1996-07-10','1996-07-24','1996-07-16',2,58.17,'Hanari Carnes','Rua do Paco, 67','Rio de Janeiro','RJ','05454-876','Brazil'),
(10254,'CHOPS',5,'1996-07-11','1996-08-08','1996-07-23',2,22.98,'Chop-suey Chinese','Hauptstr. 31','Bern',NULL,'3012','Switzerland'),
(10255,'RICSU',9,'1996-07-12','1996-08-09','1996-07-15',3,148.33,'Richter Supermarkt','Starenweg 5','Geneve',NULL,'1204','Switzerland'),
(10256,'WELLI',3,'1996-07-15','1996-08-12','1996-07-17',2,13.97,'Wellington Importadora','Rua do Mercado, 12','Resende','SP','08737-363','Brazil'),
(10257,'HILAA',4,'1996-07-16','1996-08-13','1996-07-22',3,81.91,'HILARION-Abastos','Carrera 22 con Ave. Carlos Soublette #8-35','San Cristobal','Tachira','5022','Venezuela'),
(10258,'ERNSH',1,'1996-07-17','1996-08-14','1996-07-23',1,140.51,'Ernst Handel','Kirchgasse 6','Graz',NULL,'8010','Austria'),
(10259,'CENTC',4,'1996-07-18','1996-08-15','1996-07-25',3,3.25,'Centro comercial Moctezuma','Sierras de Granada 9993','Mexico D.F.',NULL,'05022','Mexico'),
(10260,'OTTIK',4,'1996-07-19','1996-08-16','1996-07-29',1,55.09,'Ottilies Kaseladen','Mehrheimerstr. 369','Koln',NULL,'50739','Germany'),
(10261,'QUEDE',4,'1996-07-19','1996-08-16','1996-07-30',2,3.05,'Que Delicia','Rua da Panificadora, 12','Rio de Janeiro','RJ','02389-673','Brazil'),
(10262,'RATTC',8,'1996-07-22','1996-08-19','1996-07-25',3,48.29,'Rattlesnake Canyon Grocery','2817 Milton Dr.','Albuquerque','NM','87110','USA'),
(10263,'ERNSH',9,'1996-07-23','1996-08-20','1996-07-31',3,146.06,'Ernst Handel','Kirchgasse 6','Graz',NULL,'8010','Austria'),
(10264,'FOLKO',6,'1996-07-24','1996-08-21','1996-08-23',3,3.67,'Folk och fa HB','Akergatan 24','Bracke',NULL,'S-844 67','Sweden'),
(10265,'BLONP',2,'1996-07-25','1996-08-22','1996-08-12',1,55.28,'Blondesddsl pere et fils','24, place Kleber','Strasbourg',NULL,'67000','France'),
(10266,'WARTH',3,'1996-07-26','1996-09-06','1996-07-31',3,25.73,'Wartian Herkku','Torikatu 38','Oulu',NULL,'90110','Finland'),
(10267,'FRANK',4,'1996-07-29','1996-08-26','1996-08-06',1,208.58,'Frankenversand','Berliner Platz 43','Munchen',NULL,'80805','Germany')
ON CONFLICT DO NOTHING;

INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount) VALUES
(10248,11,14.00,12,0),(10248,42,9.80,10,0),(10248,72,34.80,5,0),
(10249,14,18.60,9,0),(10249,51,42.40,40,0),
(10250,41,7.70,10,0),(10250,51,42.40,35,0.15),(10250,65,16.80,15,0.15),
(10251,22,16.80,6,0.05),(10251,57,15.60,15,0.05),(10251,65,16.80,20,0),
(10252,20,64.80,40,0.05),(10252,33,2.00,25,0.05),(10252,60,27.20,40,0),
(10253,31,10.00,20,0),(10253,39,14.40,42,0),(10253,49,16.00,40,0),
(10254,24,3.60,15,0.15),(10254,55,19.20,21,0.15),(10254,74,8.00,21,0),
(10255,2,15.20,20,0),(10255,16,13.90,35,0),(10255,36,15.20,25,0),(10255,59,44.00,30,0),
(10256,53,26.20,15,0),(10256,77,10.40,12,0),
(10257,27,35.10,25,0),(10257,39,14.40,6,0.25),(10257,77,10.40,15,0.25),
(10258,2,15.20,50,0.2),(10258,5,17.00,65,0.2),(10258,32,25.60,6,0.2),
(10259,21,8.00,10,0),(10259,37,20.80,1,0),
(10260,41,7.70,16,0.25),(10260,57,15.60,50,0),(10260,62,39.40,15,0.25),(10260,70,12.00,21,0.25),
(10261,21,8.00,20,0),(10261,35,14.40,20,0),
(10262,5,17.00,12,0.2),(10262,7,24.00,15,0),(10262,56,30.40,2,0),
(10263,16,13.90,60,0.25),(10263,24,3.60,28,0),(10263,30,20.70,60,0.25),(10263,74,8.00,36,0.25),
(10264,2,15.20,35,0),(10264,41,7.70,25,0.15),
(10265,17,31.20,30,0),(10265,70,12.00,20,0),
(10266,12,30.40,12,0.05),
(10267,14,18.60,35,0),(10267,29,99.00,9,0),(10267,56,30.40,5,0)
ON CONFLICT DO NOTHING;

SELECT setval('orders_order_id_seq', (SELECT MAX(order_id) FROM orders));
