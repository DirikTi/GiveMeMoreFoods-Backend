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
    updatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP,
    lastLoginDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY(userId),
    UNIQUE KEY(email, username)
) ENGINE=InnoDB;

CREATE TABLE category (
    categoryId SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    categoryName CHAR(127) NOT NULL,
    description CHAR(255),
    imagePath CHAR(255) NOT NULL,
    isActive TINYINT(1) NOT NULL DEFAULT 1,
    createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    updatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
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
    productHeartUsersId BIGINT NOT NULL, 
    productId INT NOT NULL,
    categoryId SMALLINT NOT NULL,
    userId INT UNSIGNED NOT NULL,
    isHeart INT NOT NULL,
    createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    updatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP()  ON UPDATE CURRENT_TIMESTAMP(),
    PRIMARY KEY (productHeartUsersId),
    FOREIGN KEY (productId) REFERENCES products(productId),
    -- FOREIGN KEY (categoryId) REFERENCES category(categoryId),
    FOREIGN KEY (userId) REFERENCES users(userId)
) ENGINE=InnoDB; -- ENGINE=ARCHIVE;

CREATE TABLE products_visit_users (
    productHeartUsersId BIGINT NOT NULL, 
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
  id int(11) NOT NULL,
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
  createdDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP()
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

CREATE VIEW v_product AS
SELECT p.productId, p.productName, p.description AS productDesc, p.imagePath, p.images, p.isActive AS productIsActive,
c.categoryId, c.categoryName, c.description AS categoryDesc, c.isActive AS categoryIsActive, c.createdDate AS categoryCreatedDate,
u.userId AS whoCreateUserId, u.username, u.avatar, u.isActive AS userIsActive
FROM products p
INNER JOIN category c ON c.categoryId=p.categoryId
INNER JOIN users u ON u.userId=p.userId;

DELIMITER //
CREATE PROCEDURE sp_createUser(IN _email VARCHAR(127), IN _username VARCHAR(127), IN _fullname VARCHAR(127), 
IN _surname VARCHAR(127), IN password VARCHAR(127)) 
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
            VALUES (_email, _username _fullname, _surname, _password);

            SELECT 'SUCCESS' AS RESULT, 0 AS ERROR;
        ELSE
            SELECT 'SAME_USERNAME' AS RESULT, 1 AS ERROR;
        END IF;
    ELSE 
        SELECT 'SAME_EMAIL' AS RESULT, 1 AS ERROR;
    END IF;   

END

/*
    The MySQL feature for finding words, phrases,
    Boolean combinations of words, and so on within table data, in a faster,
    more convenient, and more flexible way than using the SQL LIKE operator or writing your own application-level 
    search algorithm. It uses the SQL function MATCH() and FULLTEXT indexes.
*/