CREATE TABLE users (
    userId INT UNSIGNED NOT NULL AUTO_INCREMENT,
    email CHAR(127) NOT NULL,
    fullname CHAR(127) NOT NULL,
    surname CHAR(127) NOT NULL,
    username CHAR(127) DEFAULT NULL,
    password CHAR(127) NOT NULL,
    avatar CHAR(127) NOT NULL,
    userLoginToken BINARY(16) DEFAULT NULL,
    userLoginTokenText VARCHAR(36) GENERATED ALWAYS AS (insert(insert(insert(insert(hex(userLoginToken),9,0,_utf8mb4'-'),14,0,_utf8mb4'-'),19,0,_utf8mb4'-'),24,0,_utf8mb4'-')) VIRTUAL,
    activeCode BINARY(16),
    isActive TINYINT(1) NOT NULL DEFAULT 1,
    createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    updatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
    lastLoginDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY(userId),
    UNIQUE KEY(email, username)
) ENGINE=InnoDB;

CREATE TABLE category (
    categoryId SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    categoryName CHAR(127) NOT NULL,
    description CHAR(255),
    imagePath CHAR(255) NOT NULL,
    INDEX USING BTREE (categoryId)
) ENGINE=MEMORY;

SET max_heap_table_size = 1024*1024;

CREATE TABLE products (
    productId INT NOT NULL AUTO_INCREMENT,
    categoryId SMALLINT NOT NULL,
    userId INT UNSIGNED NOT NULL,
    productName CHAR(127) NOT NULL,
    description TEXT,
    imagePath CHAR(255) NOT NULL,
    images TEXT NOT NULL,
    isActive TINYINT(1) NOT NULL DEFAULT 1,
    createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    updatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
    PRIMARY KEY (productId),
    -- FOREIGN KEY (categoryId) REFERENCES category(categoryId),
    FOREIGN KEY (userId) REFERENCES users(userId),
    FULLTEXT KEY (productName, description)
) ENGINE=InnoDB; -- ENGINE=MyISAM;

CREATE TABLE products_heart_users (
    productHeartUsersId BIGINT NOT NULL AUTO_INCREMENT, 
    productId INT NOT NULL,
    categoryId SMALLINT NOT NULL,
    userId INT UNSIGNED NOT NULL,
    isHeart TINYINT(1) NOT NULL,
    createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    updatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP()  ON UPDATE CURRENT_TIMESTAMP(),
    PRIMARY KEY (productHeartUsersId),
    FOREIGN KEY (productId) REFERENCES products(productId),
    -- FOREIGN KEY (categoryId) REFERENCES category(categoryId),
    FOREIGN KEY (userId) REFERENCES users(userId)
) ENGINE=InnoDB; -- ENGINE=ARCHIVE;

CREATE TABLE products_visit_users (
    productHeartUsersId BIGINT NOT NULL AUTO_INCREMENT, 
    productId INT NOT NULL,
    categoryId INT NOT NULL,
    userId INT UNSIGNED NOT NULL,
    visited INT NOT NULL DEFAULT 1,
    createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    updatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
    PRIMARY KEY (productHeartUsersId),
    FOREIGN KEY (productId) REFERENCES products(productId),
    -- FOREIGN KEY (categoryId) REFERENCES category(categoryId),
    FOREIGN KEY (userId) REFERENCES users(userId)
) ENGINE=InnoDB; -- ENGINE=ARCHIVE;


CREATE TABLE requests (
  id int(11) NOT NULL AUTO_INCREMENT,
  request_body text DEFAULT NULL,
  request_query text DEFAULT NULL,
  base_url char(255) DEFAULT NULL,
  headers text DEFAULT NULL,
  method char(32) DEFAULT NULL,
  response_body text DEFAULT NULL,
  sender_ip_address char(63) DEFAULT NULL,
  user_id char(100) DEFAULT NULL,
  is_error bit(1) DEFAULT NULL,
  status int(11) DEFAULT NULL,
  createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- If you don't have Engine Archive 
-- https://stackoverflow.com/questions/55241615/mysql-sys-exec-cant-open-shared-library-lib-mysqludf-sys-so-errno-11-wrong


DELIMITER $$
CREATE FUNCTION CONVERT_UUID(UUID_TOKEN CHAR(32) )
RETURNS BINARY(16)
DETERMINISTIC
BEGIN
    RETURN (
        UNHEX(REPLACE(UUID_TOKEN, '-', ''))
    );
END $$
DELIMITER ;

CREATE VIEW v_products AS
SELECT p.productId, p.productName, p.description AS productDesc, p.imagePath, p.images, p.isActive AS productIsActive,
c.categoryId, c.categoryName, c.description AS categoryDesc,
(
    SELECT COUNT(1) 
    FROM products_heart_users phu
    WHERE phu.productId=p.productId AND phu.isHeart=1
) AS heartCount,
(
    SELECT SUM(1)
    FROM products_visit_users pvu
    WHERE pvu.productId=p.productId
) AS visitCount,
u.userId AS whoCreateUserId, u.username, u.avatar, u.isActive AS userIsActive
FROM products p
INNER JOIN category c ON c.categoryId=p.categoryId
INNER JOIN users u ON u.userId=p.userId;

CREATE VIEW v_users AS
SELECT userId, username, fullname, surname, email, password, avatar, (
    SELECT COUNT(1) 
    FROM products_heart_users phu 
    WHERE phu.userId=u.userId 
    ) AS heartCount,(
    SELECT CONCAT('[',
        GROUP_CONCAT(
            JSON_OBJECT(
                'productId', p.productId,
                'productName', p.productName,
                'productImage', p.imagePath
            )
        )   
    ,']')
    FROM products_heart_users phu
    INNER JOIN products p ON p.productId=phu.productId
    WHERE phu.userId=u.userId LIMIT 50
) AS heartProducts
FROM users u;

DELIMITER //
CREATE PROCEDURE sp_createUser(IN _email VARCHAR(127), IN _username VARCHAR(127), IN _fullname VARCHAR(127), 
IN _surname VARCHAR(127), IN _password VARCHAR(127)) 
BEGIN
    DECLARE _userId INT DEFAULT 0;
    
    SELECT userId INTO _userId 
    FROM users 
    WHERE email=_email LIMIT 1;

    IF _userId=0 THEN

        SELECT userId INTO _userId
        FROM users
        WHERE username=_username LIMIT 1;

        IF _userId=0 THEN            
            INSERT INTO users (email, username, fullname, surname, password) 
            VALUES (_email, _username, _fullname, _surname, _password);

            SELECT 'SUCCESS' AS RESULT, 0 AS ERROR;
        ELSE
            SELECT 'SAME_USERNAME' AS RESULT, 1 AS ERROR;
        END IF;
    ELSE 
        SELECT 'SAME_EMAIL' AS RESULT, 1 AS ERROR;
    END IF;   

END //
DELIMITER ;




-- DATAS --
INSERT INTO `users` (`userId`, `email`, `fullname`, `surname`, `username`, `password`, `avatar`, `userLoginToken`, `userLoginTokenText`, `isActive`, `createdDate`, `updatedDate`) VALUES
(1, 'ertugruldirik35@gmail.com', 'ertugrul', 'dirik', 'Asikus', 'secret123', '', NULL, NULL, 1, '2022-11-21 14:19:10', '2022-11-21 14:19:10'),
(2, 'catly@gmail.com', 'Catly', 'Hatly', 'Pisi', 'secret123', '', NULL, NULL, 1, '2022-11-21 14:38:16', '2022-11-21 14:38:16'),
(3, 'dsa@gmail.com', 'dsa', 'asd', 'qwerty', 'secret123', '', NULL, NULL, 1, '2022-11-21 14:38:16', '2022-11-21 14:38:16');


INSERT INTO `products` (`productId`, `categoryId`, `userId`, `productName`, `description`, `imagePath`, `images`, `isActive`, `createdDate`, `updatedDate`) VALUES
(1, 1, 1, 'Sütlaç', 'Malzemeler\r\n1 litre süt\r\n2 çay bardağı yıkanmış pirinç\r\n1 su bardağı toz şeker\r\n1 paket vanilya\r\n4 su bardağı su\r\n\r\nTarifi\r\n- Sütlaç yapımı için öncelikle pirinçleri iyice yıkayın ve bir tencereye koyun.\r\n\r\n- Üzerine 4 su bardağı suyu ilave edip kaynamaya bırakın.\r\n\r\n- Kaynayınca altını kısın ve biraz daha pişirmeye devam edin. Pişirirken ara ara karıştırmayı ihmal etmeyin.\r\n\r\n- Pirinçler yumuşayıp, suyunu çekince üzerine sütü de ilave edin ve yüksek ateşte kaynayıncaya kadara sık sık karıştırarak pişirin.\r\n\r\n- Kaynamaya başlayınca altını kısın ve 20 dakika da kısık ateşte pişirin.\r\n\r\n- Daha sonra şekeri de ilave ederek karıştırmaya devam et ve 5 dakika daha pişirin ve sonra ocaktan alın.\r\n\r\n- Pişen sütlaca vanilyayı da ekleyin ve biraz daha karıştırın.\r\n\r\n- Hazır olan tatlıyı kaselere bölün ve ister soğuk ister sıcak tüketin.', '', '', 1, '2022-11-21 14:25:56', '2022-11-21 14:25:56'),
(2, 1, 1, 'Şeftalili Turta', 'Malzemeler\r\n2 adet yumurta\r\n1 paket margarin (250 gram)\r\n4, 5 su bardağı un\r\n1 su bardağı şeker\r\n1 paket kabartma tozu\r\nTartın içine;\r\n\r\n4 orta boy şeftali\r\n1/2 (yarım) su bardağı şeker\r\n\r\nTarif\r\n- Soyup doğradığımız şeftalileri şeker ile suyunu çekene kadar pişirelim. Şeftaliler soğuyana kadar tart hamurunu yapalım.\r\n\r\n- Unu ortasını açıp yumuşak margarini, yumurta, şeker ve kabartma tozunu ekleyip ele yapışmayan özlü bir hamur yoğuralım.\r\n\r\n- Hamuru ikiye ayıralım. Hamurun ayırdığımız kısmını buzluğa kaldırıp rendelenecek kıvama gelene kadar donmasını bekleyelim.\r\n\r\n- Kalan kısmını 25-30 cm çapındaki kalıba yerleştirelim.\r\n\r\n- Hamurun kenarları 1-2 cm. kadar yükseltip çatal yardımı ile delikler açalım ki hamurumuz kabarmasın.\r\n\r\n- Soğuyan şeftalili harcı yayalım üzerine de buzlukta donan hamuru meyvenin üstüne rendeleyip 180 derecede üzeri açık pembe renk alana kadar pişirelim. Afiyet olsun.', '', '', 1, '2022-11-21 14:28:26', '2022-11-21 14:28:26'),
(3, 2, 1, 'Hokkur Çorbası', 'Malzemeler\r\n3 su bardağı un\r\n1 çay kaşığı tuz\r\n5 yemek kaşığı sıvıyağ\r\n1 yemek kaşığı salça\r\nSu\r\n1 baş küçük soğan\r\n1-2 diş sarımsak\r\n\r\nTarif\r\nUnun içerisine tuzu ilave edip üzerine yavaş yavaş su ilave ediyoruz ve mantı kıvamında 1 künt hamur yapıyoruz. Daha sonra bir tencerenin içine sıvıyağı, salçayı ve minik minik doğradığımız soğanı ilave edip biraz soğanlar ölünceye kadar pişiriyoruz daha sonra üzerine 6 su bardağı sıcak su ilave ediyoruz ve iyice kaynatıyoruz.\r\nDaha sonra ocağın yanında tezgahın üzerine kündümüzü bastırarak yayıyoruz ve kaynayan suyun içine yemek kaşığı ile hamurdan parçalar koparıp atıyoruz. bunu yaparken hızlı olmak önemli  ve 2 kişi ile yapılırsa daha da iyi olur. en sonunda sarımsağımızı ezip çorbaya ilave ediyoruz ve bir süre daha kaynatıp ocaktan alıyoruz sıcak sıcak servis yapıyoruz...', '', '', 1, '2022-11-21 14:36:14', '2022-11-21 14:36:14'),
(4, 2, 1, 'Mercimek Çorbası', 'Malzemeler\r\n3 yemek kaşığı ayçiçek yağı\r\n1 adet kuru soğan (iri doğranmış)\r\n1 yemek kaşığı un\r\n1 adet havuç (iri doğranmış)\r\n1 adet patates (büyük boy, iri doğranmış)\r\n1 tatlı kaşığı tuz\r\n1 çay kaşığı karabiber\r\n1,5 su bardağı kırmızı ya da sarı mercimek\r\n6 su bardağı sıcak su (1 adet et su tablet ile hazırlanmış)\r\nÜzeri İçin:\r\n3 yemek kaşığı sıvı yağ\r\n2 yemek kaşığı tereyağı\r\n1 tatlı kaşığı kırmızı toz biber\r\n\r\nTarif\r\n- Derin bir tencereye 3 yemek kaşığı sıvı yağ ekleyin. İri doğranmış 1 adet büyük soğanı sıvı yağ ile birlikte kavurun.\r\n\r\n- Kavrulan soğanlara 1 yemek kaşığı unu ekleyin ve kokusu çıkıp, renk alana kadar kavurma işlemini sürdürün. İri parçalar halinde doğradığınız birer adet havuç ve patatesi tencereye aktarıp karıştırmaya devam edin.\r\n\r\n- Tuz, karabiber ve bol suda yıkadıktan sonra suyunu süzdürdüğünüz 1,5 su bardağı mercimeği  de ilave edin ve son kez güzelce karıştırın.\r\n\r\n- 6 su bardağı sıcak suyu da tencereye ilave edin.\r\n\r\n- Ardından kapağını kapatın, patates ve havuçlar yumuşayana kadar ara ara karıştırarak 40 dakika kadar pişirin.\r\n\r\n- Çorba piştikten sonra pürüzsüz bir kıvam alması için; el blenderından geçirin. 5 dakika daha pişirdikten sonra ocaktan alın.\r\n\r\n- 3 yemek kaşığı sıvı yağ ve 2 yemek kaşığı tereyağını bir tavada kızdırın. Üzerine 1 tatlı kaşığı toz kırmızı biberi ekleyin ve 2 dakika yağı kızdırdıktan sonra ocaktan alın.\r\n\r\n- Çorbayı bir kaseye alın ve üzerine kızdırdığınız yağdan gezdirip servis edin.', '', '', 1, '2022-11-21 14:36:14', '2022-11-21 14:36:14');


/*
    The MySQL feature for finding words, phrases,
    Boolean combinations of words, and so on within table data, in a faster,
    more convenient, and more flexible way than using the SQL LIKE operator or writing your own application-level 
    search algorithm. It uses the SQL function MATCH() and FULLTEXT indexes.
*/

/*
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/DirikTi/GiveMeMoreFoods.git
git push -u origin main
*/