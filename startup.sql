CREATE TABLE users (
    userId INT UNSIGNED NOT NULL AUTO_INCREMENT,
    email CHAR(127) NOT NULL,
    fullname CHAR(127) NOT NULL,
    surname CHAR(127) NOT NULL,
    username CHAR(127) NOT NULL,
    password CHAR(127) NOT NULL,
    avatar CHAR(127) NOT NULL,
    userLoginToken binary(16) DEFAULT NULL,
    userLoginTokenText varchar(36) GENERATED ALWAYS AS (insert(insert(insert(insert(hex(userLoginToken),9,0,_utf8mb4'-'),14,0,_utf8mb4'-'),19,0,_utf8mb4'-'),24,0,_utf8mb4'-')) VIRTUAL,
    isActive TINYINT(1) NOT NULL DEFAULT 1,
    createdDate TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    updatedDate TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(userId),
    UNIQUE KEY(email, username)
) ENGINE=InnoDB;

CREATE TABLE category (
    categoryId SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    categoryName CHAR(127) NOT NULL,
    description CHAR(255),
    imagePath CHAR(255) NOT NULL,
    isActive TINYINT(1) NOT NULL DEFAULT 1,
    createdDate TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    updatedDate TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
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
    createdDate TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    updatedDate TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (productId),
    -- FOREIGN KEY (categoryId) REFERENCES category(categoryId),
    FOREIGN KEY (userId) REFERENCES users(userId),
    FULLTEXT KEY (productName, description)
) ENGINE=InnoDB -- ENGINE=MyISAM;

CREATE TABLE products_heart_users (
    productHeartUsersId BIGINT NOT NULL, 
    productId INT NOT NULL,
    categoryId SMALLINT NOT NULL,
    userId INT UNSIGNED NOT NULL,
    isHeart INT NOT NULL,
    createdDate TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    updatedDate TIMESTAMP NOT NULL DEFAULT current_timestamp()  ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (productHeartUsersId),
    FOREIGN KEY (productId) REFERENCES products(productId),
    FOREIGN KEY (categoryId) REFERENCES category(categoryId),
    FOREIGN KEY (userId) REFERENCES users(userId)
) ENGINE=InnoDB -- ENGINE=ARCHIVE;

CREATE TABLE products_visit_users (
    productHeartUsersId BIGINT NOT NULL, 
    productId INT NOT NULL,
    categoryId INT NOT NULL,
    userId INT UNSIGNED NOT NULL,
    visited INT NOT NULL DEFAULT 1,
    createdDate TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    updatedDate TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (productHeartUsersId),
    FOREIGN KEY (productId) REFERENCES products(productId),
    FOREIGN KEY (categoryId) REFERENCES category(categoryId),
    FOREIGN KEY (userId) REFERENCES users(userId)
) ENGINE=InnoDB -- ENGINE=ARCHIVE;

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

/*
    The MySQL feature for finding words, phrases,
    Boolean combinations of words, and so on within table data, in a faster,
    more convenient, and more flexible way than using the SQL LIKE operator or writing your own application-level 
    search algorithm. It uses the SQL function MATCH() and FULLTEXT indexes.
*/