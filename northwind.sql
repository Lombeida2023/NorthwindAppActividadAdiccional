-- Northwind PostgreSQL Script

DROP TABLE IF EXISTS employee_territories CASCADE;
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS territories CASCADE;
DROP TABLE IF EXISTS region CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS shippers CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(15) NOT NULL,
    description TEXT,
    picture BYTEA
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24),
    home_page TEXT
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(40) NOT NULL,
    supplier_id INT REFERENCES suppliers(supplier_id),
    category_id INT REFERENCES categories(category_id),
    quantity_per_unit VARCHAR(20),
    unit_price NUMERIC(10,2) DEFAULT 0,
    units_in_stock SMALLINT DEFAULT 0,
    units_on_order SMALLINT DEFAULT 0,
    reorder_level SMALLINT DEFAULT 0,
    discontinued BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE customers (
    customer_id CHAR(5) PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24)
);

CREATE TABLE region (
    region_id SERIAL PRIMARY KEY,
    region_description CHAR(50) NOT NULL
);

CREATE TABLE territories (
    territory_id VARCHAR(20) PRIMARY KEY,
    territory_description CHAR(50) NOT NULL,
    region_id INT NOT NULL REFERENCES region(region_id)
);

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(10) NOT NULL,
    title VARCHAR(30),
    title_of_courtesy VARCHAR(25),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    home_phone VARCHAR(24),
    extension VARCHAR(4),
    notes TEXT,
    reports_to INT REFERENCES employees(employee_id),
    photo_path VARCHAR(255)
);

CREATE TABLE employee_territories (
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    territory_id VARCHAR(20) NOT NULL REFERENCES territories(territory_id),
    PRIMARY KEY (employee_id, territory_id)
);

CREATE TABLE shippers (
    shipper_id SERIAL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    phone VARCHAR(24)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id CHAR(5) REFERENCES customers(customer_id),
    employee_id INT REFERENCES employees(employee_id),
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via INT REFERENCES shippers(shipper_id),
    freight NUMERIC(10,2) DEFAULT 0,
    ship_name VARCHAR(40),
    ship_address VARCHAR(60),
    ship_city VARCHAR(15),
    ship_region VARCHAR(15),
    ship_postal_code VARCHAR(10),
    ship_country VARCHAR(15)
);

CREATE TABLE order_details (
    order_id INT NOT NULL REFERENCES orders(order_id),
    product_id INT NOT NULL REFERENCES products(product_id),
    unit_price NUMERIC(10,2) NOT NULL DEFAULT 0,
    quantity SMALLINT NOT NULL DEFAULT 1,
    discount REAL NOT NULL DEFAULT 0,
    PRIMARY KEY (order_id, product_id)
);

-- CATEGORIES
INSERT INTO categories (category_name, description) VALUES
('Beverages','Soft drinks, coffees, teas, beers, and ales'),
('Condiments','Sweet and savory sauces, relishes, spreads, and seasonings'),
('Confections','Desserts, candies, and sweet breads'),
('Dairy Products','Cheeses'),
('Grains/Cereals','Breads, crackers, pasta, and cereal'),
('Meat/Poultry','Prepared meats'),
('Produce','Dried fruit and bean curd'),
('Seafood','Seaweed and fish');

-- SUPPLIERS
INSERT INTO suppliers (company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax) VALUES
('Exotic Liquids','Charlotte Cooper','Purchasing Manager','49 Gilbert St.','London',NULL,'EC1 4SD','UK','(171) 555-2222',NULL),
('New Orleans Cajun Delights','Shelley Burke','Order Administrator','P.O. Box 78934','New Orleans','LA','70117','USA','(100) 555-4822',NULL),
('Grandma Kelly''s Homestead','Regina Murphy','Sales Representative','707 Oxford Rd.','Ann Arbor','MI','48104','USA','(313) 555-5735','(313) 555-3349'),
('Tokyo Traders','Yoshi Nagase','Marketing Manager','9-8 Sekimai Musashino-shi','Tokyo',NULL,'100','Japan','(03) 3555-5011',NULL),
('Cooperativa de Quesos ''Las Cabras''','Antonio del Valle Saavedra','Export Administrator','Calle del Rosal 4','Oviedo','Asturias','33007','Spain','(98) 598 76 54',NULL),
('Mayumi''s','Mayumi Ohara','Marketing Representative','92 Setsuko Chuo-ku','Osaka',NULL,'545','Japan','(06) 431-7877','(06) 431-7828'),
('Pavlova, Ltd.','Ian Devling','Marketing Manager','74 Rose St. Moonie Ponds','Melbourne','Victoria','3058','Australia','(03) 444-2343','(03) 444-6588'),
('Specialty Biscuits, Ltd.','Peter Wilson','Sales Representative','29 King''s Way','Manchester',NULL,'M14 GSD','UK','(161) 555-4448',NULL),
('PB Knäckebröd AB','Lars Peterson','Sales Agent','Kaloadagatan 13','Göteborg',NULL,'S-345 67','Sweden','031-987 65 43','031-987 65 91'),
('Refrescos Americanas LTDA','Carlos Diaz','Marketing Manager','Av. das Americanas 12.890','Sao Paulo',NULL,'5442','Brazil','(11) 555 4640',NULL),
('Heli Süßwaren GmbH & Co. KG','Petra Winkler','Sales Manager','Tiergartenstraße 5','Berlin',NULL,'10785','Germany','(010) 9984510',NULL),
('Plutzer Lebensmittelgroßmärkte AG','Martin Bein','International Marketing Mgr','Bogenallee 51','Frankfurt',NULL,'60439','Germany','(069) 992755',NULL),
('Nord-Ost-Fisch Handelsgesellschaft mbH','Sven Petersen','Coordinator Foreign Markets','Frahmredder 112a','Cuxhaven',NULL,'27478','Germany','(04721) 8713','(04721) 8714'),
('Formaggi Fortini s.r.l.','Elio Rossi','Sales Representative','Viale Dante, 75','Ravenna',NULL,'48100','Italy','(0544) 60323','(0544) 60603'),
('Norske Meierier','Beate Vileid','Marketing Manager','Hatlevegen 5','Sandvika',NULL,'1320','Norway','(0)2-953010',NULL),
('Bigfoot Breweries','Cheryl Saylor','Regional Account Rep.','3400 - 8th Avenue Suite 210','Bend','OR','97101','USA','(503) 555-9931',NULL),
('Svensk Sjöföda AB','Michael Björn','Sales Representative','Brovallavägen 231','Stockholm',NULL,'S-123 45','Sweden','08-123 45 67',NULL),
('Aux joyeux ecclésiastiques','Guylène Nodier','Sales Manager','203, Rue des Francs-Bourgeois','Paris',NULL,'75004','France','(1) 03.83.00.68','(1) 03.83.00.62'),
('New England Seafood Cannery','Robb Merchant','Wholesale Account Agent','Order Processing Dept. 2100 Paul Revere Blvd.','Boston','MA','02134','USA','(617) 555-3267','(617) 555-3389'),
('Leka Trading','Chandra Leka','Owner','471 Serangoon Loop, Suite #402','Singapore',NULL,'0512','Singapore','555-8787',NULL),
('Lyngbysild','Niels Petersen','Sales Manager','Lyngbysild Fiskebakken 10','Lyngby',NULL,'2800','Denmark','43844108','43844115'),
('Zaanse Snoepfabriek','Dirk Luchte','Accounting Manager','Verkoop Rijnweg 22','Zaandam',NULL,'9999 ZZ','Netherlands','(12345) 1212','(12345) 1210'),
('Karkki Oy','Anne Heikkonen','Product Manager','Valtakatu 12','Lappeenranta',NULL,'53120','Finland','(953) 10956',NULL),
('G''day, Mate','Wendy Mackenzie','Sales Representative','170 Prince Edward Parade Hunter''s Hill','Sydney','NSW','2042','Australia','(02) 555-5914','(02) 555-4873'),
('Ma Maison','Jean-Guy Lauzon','Marketing Manager','2960 Rue St. Laurent','Montréal','Québec','H1J 1C3','Canada','(514) 555-9022',NULL),
('Pasta Buttini s.r.l.','Giovanni Giudici','Order Administrator','Via dei Gelsomini, 153','Salerno',NULL,'84100','Italy','(089) 6547665','(089) 6547667'),
('Escargots Nouveaux','Marie Delamare','Sales Manager','22, rue H. Voiron','Montceau',NULL,'71300','France','85.57.00.07',NULL),
('Gai pâturage','Eliane Noz','Sales Representative','Bat. B 3, rue des Alpes','Annecy',NULL,'74000','France','38.76.98.06','38.76.98.58'),
('Forêts d''érables','Chantal Goulet','Accounting Manager','148 rue Chasseur','Ste-Hyacinthe','Québec','J2S 7S8','Canada','(514) 555-2955','(514) 555-2921');

-- PRODUCTS
INSERT INTO products (product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued) VALUES
('Chai',1,1,'10 boxes x 20 bags',18.00,39,0,10,FALSE),
('Chang',1,1,'24 - 12 oz bottles',19.00,17,40,25,FALSE),
('Aniseed Syrup',1,2,'12 - 550 ml bottles',10.00,13,70,25,FALSE),
('Chef Anton''s Cajun Seasoning',2,2,'48 - 6 oz jars',22.00,53,0,0,FALSE),
('Chef Anton''s Gumbo Mix',2,2,'36 boxes',21.35,0,0,0,TRUE),
('Grandma''s Boysenberry Spread',3,2,'12 - 8 oz jars',25.00,120,0,25,FALSE),
('Uncle Bob''s Organic Dried Pears',3,7,'12 - 1 lb pkgs.',30.00,15,0,10,FALSE),
('Northwoods Cranberry Sauce',3,2,'12 - 12 oz jars',40.00,6,0,0,FALSE),
('Mishi Kobe Niku',4,6,'18 - 500 g pkgs.',97.00,29,0,0,TRUE),
('Ikura',4,8,'12 - 200 ml jars',31.00,31,0,0,FALSE),
('Queso Cabrales',5,4,'1 kg pkg.',21.00,22,30,30,FALSE),
('Queso Manchego La Pastora',5,4,'10 - 500 g pkgs.',38.00,86,0,0,FALSE),
('Konbu',6,8,'2 kg box',6.00,24,0,5,FALSE),
('Tofu',6,7,'40 - 100 g pkgs.',23.25,35,0,0,FALSE),
('Genen Shouyu',6,2,'24 - 250 ml bottles',15.50,39,0,5,FALSE),
('Pavlova',7,3,'32 - 500 g boxes',17.45,29,0,10,FALSE),
('Alice Mutton',7,6,'20 - 1 kg tins',39.00,0,0,0,TRUE),
('Carnarvon Tigers',7,8,'16 kg pkg.',62.50,42,0,0,FALSE),
('Teatime Chocolate Biscuits',8,3,'10 boxes x 12 pieces',9.20,25,0,5,FALSE),
('Sir Rodney''s Marmalade',8,3,'30 gift boxes',81.00,40,0,0,FALSE),
('Sir Rodney''s Scones',8,3,'24 pkgs. x 4 pieces',10.00,3,40,5,FALSE),
('Gustaf''s Knäckebröd',9,5,'24 - 500 g pkgs.',21.00,104,0,25,FALSE),
('Tunnbröd',9,5,'12 - 250 g pkgs.',9.00,61,0,25,FALSE),
('Guaraná Fantástica',10,1,'12 - 355 ml cans',4.50,20,0,0,TRUE),
('NuNuCa Nuß-Nougat-Creme',11,3,'20 - 450 g glasses',14.00,76,0,30,FALSE),
('Gumbär Gummibärchen',11,3,'100 - 250 g bags',31.23,15,0,0,FALSE),
('Schoggi Schokolade',11,3,'100 - 100 g pieces',43.90,49,0,30,FALSE),
('Rössle Sauerkraut',12,7,'25 - 825 g cans',45.60,26,0,0,TRUE),
('Thüringer Rostbratwurst',12,6,'50 bags x 30 sausgs.',123.79,0,0,0,TRUE),
('Nord-Ost Matjeshering',13,8,'10 - 200 g glasses',25.89,10,0,15,FALSE),
('Gorgonzola Telino',14,4,'12 - 100 g pkgs',12.50,0,70,20,FALSE),
('Mascarpone Fabioli',14,4,'24 - 200 g pkgs.',32.00,9,40,25,FALSE),
('Geitost',15,4,'500 g',2.50,112,0,20,FALSE),
('Sasquatch Ale',16,1,'24 - 12 oz bottles',14.00,111,0,15,FALSE),
('Steeleye Stout',16,1,'24 - 12 oz bottles',18.00,20,0,15,FALSE),
('Inlagd Sill',17,8,'24 - 250 g  jars',19.00,112,0,20,FALSE),
('Gravad lax',17,8,'12 - 500 g pkgs.',26.00,11,50,25,FALSE),
('Côte de Blaye',18,1,'12 - 75 cl bottles',263.50,17,0,15,FALSE),
('Chartreuse verte',18,1,'750 cc per bottle',18.00,69,0,5,FALSE),
('Boston Crab Meat',19,8,'24 - 4 oz tins',18.40,123,0,30,FALSE),
('Jack''s New England Clam Chowder',19,8,'12 - 12 oz cans',9.65,85,0,10,FALSE),
('Singaporean Hokkien Fried Mee',20,5,'32 - 1 kg pkgs.',14.00,26,0,0,TRUE),
('Ipoh Coffee',20,1,'16 - 500 g tins',46.00,17,10,25,FALSE),
('Gula Malacca',20,2,'20 - 2 kg bags',19.45,27,0,15,FALSE),
('Røgede sild',21,8,'1k pkg.',9.50,5,70,15,FALSE),
('Spegesild',21,8,'4 - 450 g glasses',12.00,95,0,0,FALSE),
('Zaanse koeken',22,3,'10 - 4 oz boxes',9.50,36,0,0,FALSE),
('Chocolade',22,3,'10 pkgs.',12.75,15,70,25,FALSE),
('Maxilaku',23,3,'24 - 50 g pkgs.',20.00,10,60,15,FALSE),
('Valkoinen suklaa',23,3,'12 - 100 g bars',16.25,65,0,30,FALSE),
('Manjimup Dried Apples',24,7,'50 - 300 g pkgs.',53.00,20,0,10,FALSE),
('Filo Mix',24,5,'16 - 2 kg boxes',7.00,38,0,25,FALSE),
('Perth Pasties',24,6,'48 pieces',32.80,0,0,0,TRUE),
('Tourtière',25,6,'16 pies',7.45,21,0,10,FALSE),
('Pâté chinois',25,6,'24 boxes x 2 pies',24.00,115,0,20,FALSE),
('Gnocchi di nonna Alice',26,5,'24 - 250 g pkgs.',38.00,21,10,30,FALSE),
('Ravioli Angelo',26,5,'24 - 250 g pkgs.',19.50,36,0,20,FALSE),
('Escargots de Bourgogne',27,8,'24 pieces',13.25,62,0,20,FALSE),
('Raclette Courdavault',28,4,'5 kg pkg.',55.00,79,0,0,FALSE),
('Camembert Pierrot',28,4,'15 - 300 g rounds',34.00,19,0,0,FALSE),
('Sirop d''érable',29,2,'24 - 500 ml bottles',28.50,113,0,25,FALSE),
('Tarte au sucre',29,3,'48 pies',49.30,17,0,0,FALSE),
('Vegie-spread',7,2,'15 - 625 g jars',43.90,24,0,5,FALSE),
('Wimmers gute Semmelknödel',12,5,'20 bags x 4 pieces',33.25,22,80,30,FALSE),
('Louisiana Fiery Hot Pepper Sauce',2,2,'32 - 8 oz bottles',21.05,76,0,0,FALSE),
('Louisiana Hot Spiced Okra',2,2,'24 - 8 oz jars',17.00,4,100,20,FALSE),
('Laughing Lumberjack Lager',16,1,'24 - 12 oz bottles',14.00,52,0,10,FALSE),
('Scottish Longbreads',8,3,'10 boxes x 8 pieces',12.50,6,10,15,FALSE),
('Gudbrandsdalsost',15,4,'10 kg pkg.',36.00,26,0,15,FALSE),
('Outback Lager',7,1,'24 - 355 ml bottles',15.00,15,10,30,FALSE),
('Flotemysost',15,4,'10 - 500 g pkgs.',21.50,26,0,0,FALSE),
('Mozzarella di Giovanni',14,4,'24 - 200 g pkgs.',34.80,14,0,0,FALSE),
('Röd Kaviar',17,8,'24 - 150 g jars',15.00,101,0,5,FALSE),
('Longlife Tofu',4,7,'5 kg pkg.',10.00,4,20,5,FALSE),
('Rhönbräu Klosterbier',12,1,'24 - 0.5 l bottles',7.75,125,0,25,FALSE),
('Lakkalikööri',23,1,'500 ml',18.00,57,0,20,FALSE),
('Original Frankfurter grüne Soße',12,2,'12 boxes',13.00,32,0,15,FALSE);

-- REGION
INSERT INTO region (region_id, region_description) VALUES
(1,'Eastern'),
(2,'Western'),
(3,'Northern'),
(4,'Southern');

-- SHIPPERS
INSERT INTO shippers (company_name, phone) VALUES
('Speedy Express','(503) 555-9831'),
('United Package','(503) 555-3199'),
('Federal Shipping','(503) 555-9931');

-- EMPLOYEES
INSERT INTO employees (last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, region, postal_code, country, home_phone, extension, notes, reports_to) VALUES
('Davolio','Nancy','Sales Representative','Ms.','1968-12-08','1992-05-01','507 - 20th Ave. E. Apt. 2A','Seattle','WA','98122','USA','(206) 555-9857','5467','Education includes a BA in psychology from Colorado State University.',NULL),
('Fuller','Andrew','Vice President, Sales','Dr.','1952-02-19','1992-08-14','908 W. Capital Way','Tacoma','WA','98401','USA','(206) 555-9482','3457','Andrew received his BTS commercial in 1974, with distinction.',NULL),
('Leverling','Janet','Sales Representative','Ms.','1963-08-30','1992-04-01','722 Moss Bay Blvd.','Kirkland','WA','98033','USA','(206) 555-3412','3355','Janet has a BS degree in chemistry from Boston College.',2),
('Peacock','Margaret','Sales Representative','Mrs.','1937-09-19','1993-05-03','4110 Old Redmond Rd.','Redmond','WA','98052','USA','(206) 555-8122','5176','Margaret holds a BA in English literature from Concordia College.',2),
('Buchanan','Steven','Sales Manager','Mr.','1955-03-04','1993-10-17','14 Garrett Hill','London',NULL,'SW1 8JR','UK','(71) 555-4848','3453','Steven Buchanan graduated from St. Andrews University.',2),
('Suyama','Michael','Sales Representative','Mr.','1963-07-02','1993-10-17','Coventry House Miner Rd.','London',NULL,'EC2 7JR','UK','(71) 555-7773','428','Michael is a graduate of Sussex University',5),
('King','Robert','Sales Representative','Mr.','1960-05-29','1994-01-02','Edgeham Hollow Winchester Way','London',NULL,'RG1 9SP','UK','(71) 555-5598','465','Robert King served in the Peace Corps.',5),
('Callahan','Laura','Inside Sales Coordinator','Ms.','1958-01-09','1994-03-05','4726 - 11th Ave. N.E.','Seattle','WA','98105','USA','(206) 555-1189','2344','Laura received a BA in psychology from the University of Washington.',2),
('Dodsworth','Anne','Sales Representative','Ms.','1966-01-27','1994-11-15','7 Houndstooth Rd.','London',NULL,'WG2 7LT','UK','(71) 555-4444','452','Anne has a BA degree in English from St. Lawrence College.',5);

-- CUSTOMERS (subset)
INSERT INTO customers (customer_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax) VALUES
('ALFKI','Alfreds Futterkiste','Maria Anders','Sales Representative','Obere Str. 57','Berlin',NULL,'12209','Germany','030-0074321','030-0076545'),
('ANATR','Ana Trujillo Emparedados y helados','Ana Trujillo','Owner','Avda. de la Constitución 2222','México D.F.',NULL,'05021','Mexico','(5) 555-4729','(5) 555-3745'),
('ANTON','Antonio Moreno Taquería','Antonio Moreno','Owner','Mataderos  2312','México D.F.',NULL,'05023','Mexico','(5) 555-3932',NULL),
('AROUT','Around the Horn','Thomas Hardy','Sales Representative','120 Hanover Sq.','London',NULL,'WA1 1DP','UK','(171) 555-7788','(171) 555-6750'),
('BERGS','Berglunds snabbköp','Christina Berglund','Order Administrator','Berguvsvägen  8','Luleå',NULL,'S-958 22','Sweden','0921-12 34 65','0921-12 34 67'),
('BLAUS','Blauer See Delikatessen','Hanna Moos','Sales Representative','Forsterstr. 57','Mannheim',NULL,'68306','Germany','0621-08460','0621-08924'),
('BLONP','Blondesddsl père et fils','Frédérique Citeaux','Marketing Manager','24, place Kléber','Strasbourg',NULL,'67000','France','88.60.15.31','88.60.15.32'),
('BOLID','Bólido Comidas preparadas','Martín Sommer','Owner','C/ Araquil, 67','Madrid',NULL,'28023','Spain','(91) 555 22 82','(91) 555 91 99'),
('BONAP','Bon app''','Laurence Lebihan','Owner','12, rue des Bouchers','Marseille',NULL,'13008','France','91.24.45.40','91.24.45.41'),
('BOTTM','Bottom-Dollar Markets','Elizabeth Lincoln','Accounting Manager','23 Tsawassen Blvd.','Tsawassen','BC','T2F 8M4','Canada','(604) 555-4729','(604) 555-3745'),
('BSBEV','B''s Beverages','Victoria Ashworth','Sales Representative','Fauntleroy Circus','London',NULL,'EC2 5NT','UK','(171) 555-1212',NULL),
('CACTU','Cactus Comidas para llevar','Patricio Simpson','Sales Agent','Cerrito 333','Buenos Aires',NULL,'1010','Argentina','(1) 135-5555','(1) 135-4892'),
('CENTC','Centro comercial Moctezuma','Francisco Chang','Marketing Manager','Sierras de Granada 9993','México D.F.',NULL,'05022','Mexico','(5) 555-3392','(5) 555-7293'),
('CHOPS','Chop-suey Chinese','Yang Wang','Owner','Hauptstr. 29','Bern',NULL,'3012','Switzerland','0452-076545',NULL),
('COMMI','Comércio Mineiro','Pedro Afonso','Sales Associate','Av. dos Lusíadas, 23','Sao Paulo','SP','05432-043','Brazil','(11) 555-7647',NULL),
('CONSH','Consolidated Holdings','Elizabeth Brown','Sales Representative','Berkeley Gardens 12  Brewery','London',NULL,'WX1 6LT','UK','(171) 555-2282','(171) 555-9199'),
('DRACD','Drachenblut Delikatessen','Sven Ottlieb','Order Administrator','Walserweg 21','Aachen',NULL,'52066','Germany','0241-039123','0241-059428'),
('DUMON','Du monde entier','Janine Labrune','Owner','67, rue des Cinquante Otages','Nantes',NULL,'44000','France','40.67.88.88','40.67.89.89'),
('EASTC','Eastern Connection','Ann Devon','Sales Agent','35 King George','London',NULL,'WX3 6FW','UK','(171) 555-0297','(171) 555-3373'),
('ERNSH','Ernst Handel','Roland Mendel','Sales Manager','Kirchgasse 6','Graz',NULL,'8010','Austria','7675-3425','7675-3426');

-- ORDERS (subset - 20 recent orders)
INSERT INTO orders (order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country) VALUES
(10248,'VINET',5,'1996-07-04','1996-08-01','1996-07-16',3,32.38,'Vins et alcools Chevalier','59 rue de l''Abbaye','Reims',NULL,'51100','France'),
(10249,'TOMSP',6,'1996-07-05','1996-08-16','1996-07-10',1,11.61,'Toms Spezialitäten','Luisenstr. 48','Münster',NULL,'44087','Germany'),
(10250,'HANAR',4,'1996-07-08','1996-08-05','1996-07-12',2,65.83,'Hanari Carnes','Rua do Paço, 67','Rio de Janeiro','RJ','05454-876','Brazil'),
(10251,'VICTE',3,'1996-07-08','1996-08-05','1996-07-15',1,41.34,'Victuailles en stock','2, rue du Commerce','Lyon',NULL,'69004','France'),
(10252,'SUPRD',4,'1996-07-09','1996-08-06','1996-07-11',2,51.30,'Suprêmes délices','Boulevard Tirou, 255','Charleroi',NULL,'B-6000','Belgium'),
(10253,'HANAR',3,'1996-07-10','1996-07-24','1996-07-16',2,58.17,'Hanari Carnes','Rua do Paço, 67','Rio de Janeiro','RJ','05454-876','Brazil'),
(10254,'CHOPS',5,'1996-07-11','1996-08-08','1996-07-23',2,22.98,'Chop-suey Chinese','Hauptstr. 31','Bern',NULL,'3012','Switzerland'),
(10255,'RICSU',9,'1996-07-12','1996-08-09','1996-07-15',3,148.33,'Richter Supermarkt','Starenweg 5','Genève',NULL,'1204','Switzerland'),
(10256,'WELLI',3,'1996-07-15','1996-08-12','1996-07-17',2,13.97,'Wellington Importadora','Rua do Mercado, 12','Resende','SP','08737-363','Brazil'),
(10257,'HILAA',4,'1996-07-16','1996-08-13','1996-07-22',3,81.91,'HILARION-Abastos','Carrera 22 con Ave. Carlos Soublette #8-35','San Cristóbal','Táchira','5022','Venezuela'),
(10258,'ERNSH',1,'1996-07-17','1996-08-14','1996-07-23',1,140.51,'Ernst Handel','Kirchgasse 6','Graz',NULL,'8010','Austria'),
(10259,'CENTC',4,'1996-07-18','1996-08-15','1996-07-25',3,3.25,'Centro comercial Moctezuma','Sierras de Granada 9993','México D.F.',NULL,'05022','Mexico'),
(10260,'OTTIK',4,'1996-07-19','1996-08-16','1996-07-29',1,55.09,'Ottilies Käseladen','Mehrheimerstr. 369','Köln',NULL,'50739','Germany'),
(10261,'QUEDE',4,'1996-07-19','1996-08-16','1996-07-30',2,3.05,'Que Delícia','Rua da Panificadora, 12','Rio de Janeiro','RJ','02389-673','Brazil'),
(10262,'RATTC',8,'1996-07-22','1996-08-19','1996-07-25',3,48.29,'Rattlesnake Canyon Grocery','2817 Milton Dr.','Albuquerque','NM','87110','USA'),
(10263,'ERNSH',9,'1996-07-23','1996-08-20','1996-07-31',3,146.06,'Ernst Handel','Kirchgasse 6','Graz',NULL,'8010','Austria'),
(10264,'FOLKO',6,'1996-07-24','1996-08-21','1996-08-23',3,3.67,'Folk och fä HB','Åkergatan 24','Bräcke',NULL,'S-844 67','Sweden'),
(10265,'BLONP',2,'1996-07-25','1996-08-22','1996-08-12',1,55.28,'Blondesddsl père et fils','24, place Kléber','Strasbourg',NULL,'67000','France'),
(10266,'WARTH',3,'1996-07-26','1996-09-06','1996-07-31',3,25.73,'Wartian Herkku','Torikatu 38','Oulu',NULL,'90110','Finland'),
(10267,'FRANK',4,'1996-07-29','1996-08-26','1996-08-06',1,208.58,'Frankenversand','Berliner Platz 43','München',NULL,'80805','Germany');

-- ORDER_DETAILS (subset)
INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount) VALUES
(10248,11,14.00,12,0),
(10248,42,9.80,10,0),
(10248,72,34.80,5,0),
(10249,14,18.60,9,0),
(10249,51,42.40,40,0),
(10250,41,7.70,10,0),
(10250,51,42.40,35,0.15),
(10250,65,16.80,15,0.15),
(10251,22,16.80,6,0.05),
(10251,57,15.60,15,0.05),
(10251,65,16.80,20,0),
(10252,20,64.80,40,0.05),
(10252,33,2.00,25,0.05),
(10252,60,27.20,40,0),
(10253,31,10.00,20,0),
(10253,39,14.40,42,0),
(10253,49,16.00,40,0),
(10254,24,3.60,15,0.15),
(10254,55,19.20,21,0.15),
(10254,74,8.00,21,0),
(10255,2,15.20,20,0),
(10255,16,13.90,35,0),
(10255,36,15.20,25,0),
(10255,59,44.00,30,0),
(10256,53,26.20,15,0),
(10256,77,10.40,12,0),
(10257,27,35.10,25,0),
(10257,39,14.40,6,0.25),
(10257,77,10.40,15,0.25),
(10258,2,15.20,50,0.2),
(10258,5,17.00,65,0.2),
(10258,32,25.60,6,0.2),
(10259,21,8.00,10,0),
(10259,37,20.80,1,0),
(10260,41,7.70,16,0.25),
(10260,57,15.60,50,0),
(10260,62,39.40,15,0.25),
(10260,70,12.00,21,0.25),
(10261,21,8.00,20,0),
(10261,35,14.40,20,0),
(10262,5,17.00,12,0.2),
(10262,7,24.00,15,0),
(10262,56,30.40,2,0),
(10263,16,13.90,60,0.25),
(10263,24,3.60,28,0),
(10263,30,20.70,60,0.25),
(10263,74,8.00,36,0.25),
(10264,2,15.20,35,0),
(10264,41,7.70,25,0.15),
(10265,17,31.20,30,0),
(10265,70,12.00,20,0),
(10266,12,30.40,12,0.05),
(10267,14,18.60,35,0),
(10267,29,99.00,9,0),
(10267,56,30.40,5,0);

-- Sequences fix
SELECT setval('categories_category_id_seq', (SELECT MAX(category_id) FROM categories));
SELECT setval('suppliers_supplier_id_seq', (SELECT MAX(supplier_id) FROM suppliers));
SELECT setval('products_product_id_seq', (SELECT MAX(product_id) FROM products));
SELECT setval('region_region_id_seq', (SELECT MAX(region_id) FROM region));
SELECT setval('employees_employee_id_seq', (SELECT MAX(employee_id) FROM employees));
SELECT setval('shippers_shipper_id_seq', (SELECT MAX(shipper_id) FROM shippers));
SELECT setval('orders_order_id_seq', (SELECT MAX(order_id) FROM orders));
