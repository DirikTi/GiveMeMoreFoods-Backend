DROP DATABASE IF EXISTS foods;

CREATE DATABASE foods;

USE foods;

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

USE foods;

CREATE FUNCTION CONVERT_UUID(UUID_TOKEN CHAR(32) )
RETURNS BINARY(16)
DETERMINISTIC
BEGIN
    RETURN (
        UNHEX(REPLACE(UUID_TOKEN, '-', ''))
    );
END;


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

USE foods;

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

END;




-- DATAS --
INSERT INTO `users` (`userId`, `email`, `fullname`, `surname`, `username`, `password`, `avatar`, `userLoginToken`, `userLoginTokenText`, `isActive`, `createdDate`, `updatedDate`) VALUES
(1, 'ertugruldirik35@gmail.com', 'ertugrul', 'dirik', 'Asikus', 'secret123', '', NULL, NULL, 1, '2022-11-21 14:19:10', '2022-11-21 14:19:10'),
(2, 'catly@gmail.com', 'Catly', 'Hatly', 'Pisi', 'secret123', '', NULL, NULL, 1, '2022-11-21 14:38:16', '2022-11-21 14:38:16'),
(3, 'dsa@gmail.com', 'dsa', 'asd', 'qwerty', 'secret123', '', NULL, NULL, 1, '2022-11-21 14:38:16', '2022-11-21 14:38:16');


INSERT INTO `products` (`productId`, `categoryId`, `userId`, `productName`, `description`, `imagePath`, `images`, `isActive`, `createdDate`, `updatedDate`) VALUES
(1, 1, 1, 'S??tla??', 'Malzemeler\r\n1 litre s??t\r\n2 ??ay barda???? y??kanm???? pirin??\r\n1 su barda???? toz ??eker\r\n1 paket vanilya\r\n4 su barda???? su\r\n\r\nTarifi\r\n- S??tla?? yap??m?? i??in ??ncelikle pirin??leri iyice y??kay??n ve bir tencereye koyun.\r\n\r\n- ??zerine 4 su barda???? suyu ilave edip kaynamaya b??rak??n.\r\n\r\n- Kaynay??nca alt??n?? k??s??n ve biraz daha pi??irmeye devam edin. Pi??irirken ara ara kar????t??rmay?? ihmal etmeyin.\r\n\r\n- Pirin??ler yumu??ay??p, suyunu ??ekince ??zerine s??t?? de ilave edin ve y??ksek ate??te kaynay??ncaya kadara s??k s??k kar????t??rarak pi??irin.\r\n\r\n- Kaynamaya ba??lay??nca alt??n?? k??s??n ve 20 dakika da k??s??k ate??te pi??irin.\r\n\r\n- Daha sonra ??ekeri de ilave ederek kar????t??rmaya devam et ve 5 dakika daha pi??irin ve sonra ocaktan al??n.\r\n\r\n- Pi??en s??tlaca vanilyay?? da ekleyin ve biraz daha kar????t??r??n.\r\n\r\n- Haz??r olan tatl??y?? kaselere b??l??n ve ister so??uk ister s??cak t??ketin.', '', '', 1, '2022-11-21 14:25:56', '2022-11-21 14:25:56'),
(2, 1, 1, '??eftalili Turta', 'Malzemeler\r\n2 adet yumurta\r\n1 paket margarin (250 gram)\r\n4, 5 su barda???? un\r\n1 su barda???? ??eker\r\n1 paket kabartma tozu\r\nTart??n i??ine;\r\n\r\n4 orta boy ??eftali\r\n1/2 (yar??m) su barda???? ??eker\r\n\r\nTarif\r\n- Soyup do??rad??????m??z ??eftalileri ??eker ile suyunu ??ekene kadar pi??irelim. ??eftaliler so??uyana kadar tart hamurunu yapal??m.\r\n\r\n- Unu ortas??n?? a????p yumu??ak margarini, yumurta, ??eker ve kabartma tozunu ekleyip ele yap????mayan ??zl?? bir hamur yo??ural??m.\r\n\r\n- Hamuru ikiye ay??ral??m. Hamurun ay??rd??????m??z k??sm??n?? buzlu??a kald??r??p rendelenecek k??vama gelene kadar donmas??n?? bekleyelim.\r\n\r\n- Kalan k??sm??n?? 25-30 cm ??ap??ndaki kal??ba yerle??tirelim.\r\n\r\n- Hamurun kenarlar?? 1-2 cm. kadar y??kseltip ??atal yard??m?? ile delikler a??al??m ki hamurumuz kabarmas??n.\r\n\r\n- So??uyan ??eftalili harc?? yayal??m ??zerine de buzlukta donan hamuru meyvenin ??st??ne rendeleyip 180 derecede ??zeri a????k pembe renk alana kadar pi??irelim. Afiyet olsun.', '', '', 1, '2022-11-21 14:28:26', '2022-11-21 14:28:26'),
(3, 2, 1, 'Hokkur ??orbas??', 'Malzemeler\r\n3 su barda???? un\r\n1 ??ay ka???????? tuz\r\n5 yemek ka???????? s??v??ya??\r\n1 yemek ka???????? sal??a\r\nSu\r\n1 ba?? k??????k so??an\r\n1-2 di?? sar??msak\r\n\r\nTarif\r\nUnun i??erisine tuzu ilave edip ??zerine yava?? yava?? su ilave ediyoruz ve mant?? k??vam??nda 1 k??nt hamur yap??yoruz. Daha sonra bir tencerenin i??ine s??v??ya????, sal??ay?? ve minik minik do??rad??????m??z so??an?? ilave edip biraz so??anlar ??l??nceye kadar pi??iriyoruz daha sonra ??zerine 6 su barda???? s??cak su ilave ediyoruz ve iyice kaynat??yoruz.\r\nDaha sonra oca????n yan??nda tezgah??n ??zerine k??nd??m??z?? bast??rarak yay??yoruz ve kaynayan suyun i??ine yemek ka???????? ile hamurdan par??alar kopar??p at??yoruz. bunu yaparken h??zl?? olmak ??nemli  ve 2 ki??i ile yap??l??rsa daha da iyi olur. en sonunda sar??msa????m??z?? ezip ??orbaya ilave ediyoruz ve bir s??re daha kaynat??p ocaktan al??yoruz s??cak s??cak servis yap??yoruz...', '', '', 1, '2022-11-21 14:36:14', '2022-11-21 14:36:14'),
(4, 2, 1, 'Mercimek ??orbas??', 'Malzemeler\r\n3 yemek ka???????? ay??i??ek ya????\r\n1 adet kuru so??an (iri do??ranm????)\r\n1 yemek ka???????? un\r\n1 adet havu?? (iri do??ranm????)\r\n1 adet patates (b??y??k boy, iri do??ranm????)\r\n1 tatl?? ka???????? tuz\r\n1 ??ay ka???????? karabiber\r\n1,5 su barda???? k??rm??z?? ya da sar?? mercimek\r\n6 su barda???? s??cak su (1 adet et su tablet ile haz??rlanm????)\r\n??zeri ????in:\r\n3 yemek ka???????? s??v?? ya??\r\n2 yemek ka???????? tereya????\r\n1 tatl?? ka???????? k??rm??z?? toz biber\r\n\r\nTarif\r\n- Derin bir tencereye 3 yemek ka???????? s??v?? ya?? ekleyin. ??ri do??ranm???? 1 adet b??y??k so??an?? s??v?? ya?? ile birlikte kavurun.\r\n\r\n- Kavrulan so??anlara 1 yemek ka???????? unu ekleyin ve kokusu ????k??p, renk alana kadar kavurma i??lemini s??rd??r??n. ??ri par??alar halinde do??rad??????n??z birer adet havu?? ve patatesi tencereye aktar??p kar????t??rmaya devam edin.\r\n\r\n- Tuz, karabiber ve bol suda y??kad??ktan sonra suyunu s??zd??rd??????n??z 1,5 su barda???? mercime??i  de ilave edin ve son kez g??zelce kar????t??r??n.\r\n\r\n- 6 su barda???? s??cak suyu da tencereye ilave edin.\r\n\r\n- Ard??ndan kapa????n?? kapat??n, patates ve havu??lar yumu??ayana kadar ara ara kar????t??rarak 40 dakika kadar pi??irin.\r\n\r\n- ??orba pi??tikten sonra p??r??zs??z bir k??vam almas?? i??in; el blender??ndan ge??irin. 5 dakika daha pi??irdikten sonra ocaktan al??n.\r\n\r\n- 3 yemek ka???????? s??v?? ya?? ve 2 yemek ka???????? tereya????n?? bir tavada k??zd??r??n. ??zerine 1 tatl?? ka???????? toz k??rm??z?? biberi ekleyin ve 2 dakika ya???? k??zd??rd??ktan sonra ocaktan al??n.\r\n\r\n- ??orbay?? bir kaseye al??n ve ??zerine k??zd??rd??????n??z ya??dan gezdirip servis edin.', '', '', 1, '2022-11-21 14:36:14', '2022-11-21 14:36:14'),
(5, 3, 2, 'Perde Pilav??', 'Perde Pilav??n??n i?? pilav?? i??in:\r\n3 su barda???? pirin??\r\n2 yemek ka???????? tereya????\r\n4.5 su barda???? su ve tavuk suyu kar??????m??\r\n2 adet tavuk budu\r\nYar??m kahve fincan?? ku?? ??z??m??\r\n200 g ??i?? badem\r\n1 kahve fincan?? dolmal??k f??st??k\r\nKarabiber, tuz\r\n\r\nPerde Pilav??n??n Hamuru i??in:\r\n2 adet yumurta\r\n4 yemek ka???????? yo??urt\r\nYar??m su barda???? zeytinya????\r\nTuz\r\nAld?????? kadar un\r\n\r\nTarif\r\n- Perde pilav?? yap??m??na ilk olarak tavuk butlar??n??n ha??lanmas?? ile ba??lad??m. Tavuklar?? ha??lad??ktan sonra tavuk suyu ile pilav??n yap??m??na ba??lad??m.\r\n\r\n- Margarini pilav tenceresinde eritin ve y??kay??p suyunu iyice s??zd??????n??n pirin??leri ya??da 3-4 dakika kadar kavurun.\r\n\r\n- Ha??lad??????m??z tavuklar??n suyundan 2 kasesini pirin??lerin ??zerine ekleyin.\r\n\r\n- Yar??m yemek ka???????? da tuz ekleyerek kapa????n?? kapat??n.\r\n\r\n- Pilav tam olarak pi??meden, hala diriyken ocaktan al??n.\r\n\r\n- Didikledi??iniz tavuklar??, ku?? ??z??m??n?? ve karabiberi pilav ile iyice harmanlay??n.\r\n\r\n- Hamurun yap??m??: t??m malzemeleri kar????t??rarak hamurunuzu yo??urun.\r\n\r\n- Hamuru biri k??????k biri b??y??k iki par??aya ay??r??n.\r\n\r\n- B??y??k olan?? 3 mm kal??nl??????nda a????p kab??n taban??na, kenarlar?? da kapatacak ??ekilde g??zelce yerle??tirin.\r\n\r\n- ????ine pilav?? bo??alt??n.\r\n\r\n- Hamurun k??????k par??as??n?? da ayn?? ??ekilde a????p pilav??n ??zerine kapat??n.\r\n\r\n- 200 derece ??s??t??lm???? f??r??nda perde pilav??n?? k??zarana kadar pi??irin. Ters ??evirip servis yap??n.\r\n\r\nNot: Perde pilav??n??n g??r??n??????n?? g??zelle??tirmek i??in hamuru sermeden ??nce kab??n taban??na badem s??ralad??m.', '', '', 1, '2022-11-22 14:36:03', '2022-11-22 14:36:03'),
(6, 3, 3, 'Tavuklu Pilav', 'Tavuklu Pilav Tarifi ????in Malzemeler\r\n500 gram tavuk g??????s eti\r\n2 su barda???? pirin??\r\n1 ??ay barda???? ??ehriye\r\n3 yemek ka???????? tereya????\r\n1 su barda???? tavuk suyu\r\n2 su barda???? kaynam???? su\r\n1 tatl?? ka???????? tuz\r\n1/2 (yar??m) tatl?? ka???????? karabiber\r\n\r\nTarif\r\n- ??lk olarak tavuklar??m??z?? ha??lamak i??in tencereye koyuyoruz ve ??zerini bir parmak ge??ecek ??ekilde su ekleyerek kaynamaya b??rak??yoruz.\r\n\r\n- Ha??lanan tavuklar??m??z?? so??umas?? i??in kenara al??yoruz.\r\n\r\n- Biraz so??udu??unda tavuklar??m??z?? tiftikliyece??iz.\r\n\r\n- Bu s??rada pirin??lerimizi de ??l??k suya koyup ni??astas??n??n ????kmas??n?? bekliyoruz.\r\n\r\n- Pilav tenceresine ya????m??z?? ekleyip eridi??inde ??ehriyelerimizi kavuruyoruz.\r\n\r\n- ??ehriyelerin rengi de??i??ip, kokusu ????kt??????nda pirin??lerimizi de ekliyoruz ve 5-10 dakika kadar daha kavuruyoruz.\r\n\r\n- Daha sonra pirin??imizin ??zerine tiftikledi??imiz tavu??umuzu ekliyoruz.\r\n\r\n- 1 bardak tavuk suyu ve 2 bardak kaynam???? suyunu da ekledikten sonra tuz ve karabiberi de ilave edip bir kere kar????t??r??yoruz ve kapa????n?? kapatarak k??s??k ate??te pi??meye b??rak??yoruz. Ben pilav pi??irirken ??ok fazla kar????t??rm??yorum size de b??yle tavsiye ederim.\r\n\r\n- Pilav??m??z suyunu ??ekip tane tane oldu??unda alt??n?? kapat??p, kapa????n ??zerine demlenmesi i??in ka????t havlu koyuyoruz. Servis yaparken havluyu alarak afiyetle pilav??m??z?? yiyoruz. Ellerinize sa??l??k.', '', '', 1, '2022-11-22 14:39:02', '2022-11-22 14:39:02');


INSERT INTO `products_heart_users` (`productHeartUsersId`, `productId`, `categoryId`, `userId`, `isHeart`, `createdDate`, `updatedDate`) VALUES
(1, 2, 1, 2, 1, '2022-11-24 12:31:27', '2022-11-24 12:31:27'),
(2, 2, 1, 2, 1, '2022-11-24 12:31:27', '2022-11-24 12:31:27'),
(3, 3, 2, 1, 1, '2022-11-24 12:32:54', '2022-11-24 12:32:54'),
(4, 3, 2, 3, 0, '2022-11-24 12:32:54', '2022-11-24 12:32:54'),
(5, 1, 1, 3, 1, '2022-11-24 12:32:54', '2022-11-24 12:32:54'),
(6, 6, 3, 1, 1, '2022-11-24 12:34:42', '2022-11-24 12:34:42'),
(7, 5, 3, 2, 1, '2022-11-24 12:34:42', '2022-11-24 12:34:42');

INSERT INTO `products_visit_users` (`productHeartUsersId`, `productId`, `categoryId`, `userId`, `visited`, `createdDate`, `updatedDate`) VALUES
(1, 2, 1, 1, 1, '2022-11-24 12:35:53', '2022-11-24 12:35:53'),
(2, 1, 1, 1, 1, '2022-11-24 12:35:53', '2022-11-24 12:35:53');




-- EXPLORE FOODS

CREATE TEMPORARY TABLE temp_category AS 
SELECT cc.categoryId, SUM(cc.point) AS point 
FROM (
    SELECT phu.categoryId, (COUNT(phu.productHeartUsersId) * 2.5) AS point
    FROM  products_heart_users phu
    WHERE isHeart=1 AND userId=1
    GROUP BY phu.categoryId
    UNION ALL
    SELECT pvu.categoryId, (SUM(pvu.visited) * 0.8) AS point
    FROM products_visit_users pvu
    WHERE userId=1
    GROUP BY pvu.categoryId
) cc
GROUP BY cc.categoryId
ORDER BY cc.point DESC;

SELECT * 
FROM temp_category; 

SELECT vp.productId, vp.productName, c.categoryId 
FROM temp_category c, (
	SELECT p.productId, p.productName
    FROM v_products p
    WHERE p.categoryId=tem_category.categoryId
    LIMIT 1
) AS vp;

SELECT @sum_points:=SUM(point) FROM temp_category;
SELECT @sum_points;



SELECT * 
FROM v_products p 
INNER JOIN 

-- TREND FOODS
/*SELECT p.productId, p.productName, p.productDesc, p.imagePath, 
categoryId, heartCount, whoCreateUserId, username, avatar, (
    (
        SELECT COALESCE(
            SUM(pvu.visited) + LOG(10, DATEDIFF(CURRENT_DATE(), pvu.createdDate))
        , 0)
        FROM products_visit_users pvu
        WHERE pvu.productId=p.productId
    ) + 2.5 * heartCount
) AS trend_point
FROM v_products p
WHERE categoryId=1
GROUP BY p.productId
ORDER BY trend_point DESC
LIMIT 50;
*/
-- KE??FET KISMI


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