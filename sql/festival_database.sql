DROP SCHEMA IF EXISTS `festival_database`;
CREATE SCHEMA `festival_database`;
USE festival_database;

DROP TABLE IF EXISTS festival_location;
CREATE TABLE festival_location (
    location_id INT NOT NULL AUTO_INCREMENT,
    longitude DECIMAL(10,6) NOT NULL,
    latitude DECIMAL(10,6) NOT NULL,
    loc_address VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    continent VARCHAR(100) NOT NULL,
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    descr VARCHAR(500),
    PRIMARY KEY(location_id)
);

DROP TABLE IF EXISTS scene;
CREATE TABLE scene (
    scene_id INT NOT NULL AUTO_INCREMENT,
    scene_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    descr VARCHAR(100),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    equipment_info VARCHAR(100) NOT NULL,
    PRIMARY KEY (scene_id),
    CHECK(capacity > 0)
);

DROP TABLE IF EXISTS festival;
CREATE TABLE festival (
    festival_year YEAR(4) NOT NULL,
    starting_date DATE NOT NULL,
    location_id INT NOT NULL,
    ending_date DATE NOT NULL,
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (festival_year),
    FOREIGN KEY (location_id) REFERENCES festival_location(location_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    CHECK (ending_date >= starting_date),
    UNIQUE(location_id)
);

DROP TABLE IF EXISTS festival_event;
CREATE TABLE festival_event (
    event_id INT NOT NULL AUTO_INCREMENT,
    scene_id INT NOT NULL,
    festival_year YEAR(4) NOT NULL,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    FOREIGN KEY (festival_year) REFERENCES festival(festival_year)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (scene_id) REFERENCES scene(scene_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    PRIMARY KEY (event_id)
);

DROP TABLE IF EXISTS band;
CREATE TABLE band (
    band_id INT NOT NULL AUTO_INCREMENT,
    band_name VARCHAR(100) NOT NULL,
    website VARCHAR(100) CHECK (website like 'https://%'),
    formation_date DATE NOT NULL,
    instagram VARCHAR(100) CHECK (instagram like 'https://%'),
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (band_id)
);

DROP TABLE IF EXISTS artist;
CREATE TABLE artist (
    artist_id INT NOT NULL AUTO_INCREMENT,
    artist_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    stage_name VARCHAR(100) NOT NULL,
    descr VARCHAR(500),
    instagram VARCHAR(100) CHECK (instagram like 'https://%'),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (artist_id)
);

DROP TABLE IF EXISTS performance;
CREATE TABLE performance (
    performance_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    start_datetime DATETIME NOT NULL,
    descr VARCHAR(500),
    duration INT NOT NULL,
    performance_type VARCHAR(100) NOT NULL,
    break_duration INT NOT NULL,
    band_id INT NULL,
    artist_id INT NULL,
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    FOREIGN KEY (event_id) REFERENCES festival_event(event_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (band_id) REFERENCES band(band_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    PRIMARY KEY (performance_id),
    CHECK (duration < 180),
    CHECK (break_duration >= 5 AND break_duration <= 30),
    CHECK ((artist_id IS NOT NULL AND band_id IS NULL) OR (artist_id IS NULL AND band_id IS NOT NULL))
);

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
    staff_id INT NOT NULL AUTO_INCREMENT,
    scene_id INT NOT NULL,
    staff_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    experience INT NOT NULL CHECK (experience BETWEEN 1 AND 5),
    descr VARCHAR(500) NOT NULL,
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    FOREIGN KEY (scene_id) REFERENCES scene(scene_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    PRIMARY KEY (staff_id)
);

DROP TABLE IF EXISTS staff_event;
CREATE TABLE staff_event (
    staff_event_id INT NOT NULL AUTO_INCREMENT,
    staff_id INT NOT NULL,
    event_id INT NOT NULL,
    PRIMARY KEY (staff_event_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (event_id) REFERENCES festival_event(event_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    UNIQUE (event_id, staff_id)
);

DROP TABLE IF EXISTS equipment;
CREATE TABLE equipment (
    equipment_id INT NOT NULL AUTO_INCREMENT,
    equipment_type VARCHAR(100) NOT NULL,
    descr VARCHAR(500) NOT NULL,
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (equipment_id)
);

DROP TABLE IF EXISTS scene_equipment;
CREATE TABLE scene_equipment (
    scene_equipment_id INT NOT NULL AUTO_INCREMENT,
    quantity INT NOT NULL,
    scene_id INT NOT NULL,
    equipment_id INT NOT NULL,
    FOREIGN KEY (scene_id) REFERENCES scene(scene_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    PRIMARY KEY (scene_equipment_id)
);

DROP TABLE IF EXISTS band_artist;
CREATE TABLE band_artist (
    band_artist_id INT NOT NULL AUTO_INCREMENT,
    band_id INT NOT NULL,
    artist_id INT NOT NULL,
    FOREIGN KEY (band_id) REFERENCES band(band_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    PRIMARY KEY (band_artist_id),
    UNIQUE(artist_id,band_id)
);

DROP TABLE IF EXISTS attendee;
CREATE TABLE attendee (
    attendee_id INT NOT NULL AUTO_INCREMENT,
    attendee_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    contact_info VARCHAR(100) NOT NULL,
    attendee_address VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (attendee_id)
);      

DROP TABLE IF EXISTS ticket;
CREATE TABLE ticket (
    IAN_number BIGINT NOT NULL,  
    event_info VARCHAR(500) NOT NULL,
    owner_info VARCHAR(500) NOT NULL,
    event_id INT NOT NULL,
    attendee_id INT NOT NULL,
    ticket_type VARCHAR(100) NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_method VARCHAR(100) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    activated BOOLEAN DEFAULT FALSE NOT NULL,
    resale_available BOOLEAN DEFAULT FALSE NOT NULL,
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    descr VARCHAR(500),
    PRIMARY KEY (IAN_number),
    FOREIGN KEY (event_id) REFERENCES festival_event(event_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (attendee_id) REFERENCES attendee(attendee_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    UNIQUE(event_id,attendee_id),
    CHECK(activated = FALSE or resale_available = FALSE)
);

DROP TABLE IF EXISTS rating;
CREATE TABLE rating (
    rating_id INT NOT NULL AUTO_INCREMENT,
    IAN_number BIGINT NOT NULL,
    performance_id INT NOT NULL,
    artist_performance INT NOT NULL CHECK (artist_performance BETWEEN 1 AND 5),
    stage_presence INT NOT NULL CHECK (stage_presence BETWEEN 1 AND 5),
    setup INT NOT NULL CHECK (setup BETWEEN 1 AND 5),
    sound_and_lighting INT NOT NULL CHECK (sound_and_lighting BETWEEN 1 AND 5),
    overall_impression INT NOT NULL CHECK (overall_impression BETWEEN 1 AND 5),
    descr VARCHAR(100),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (rating_id),
    FOREIGN KEY (IAN_number) REFERENCES ticket(IAN_number)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (performance_id) REFERENCES performance(performance_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS seller;
CREATE TABLE seller (
    seller_id INT NOT NULL AUTO_INCREMENT,
    date_of_interest DATETIME NOT NULL,
    IAN_number BIGINT NOT NULL,
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    FOREIGN KEY (IAN_number) REFERENCES ticket(IAN_number)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    PRIMARY KEY (seller_id)
);


DROP TABLE IF EXISTS buyer;
CREATE TABLE buyer (
    buyer_id INT NOT NULL AUTO_INCREMENT,
    buyer_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    contact_info VARCHAR(100) NOT NULL,
    buyer_address VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    ticket_type VARCHAR(100),      
    event_id INT NOT NULL,         
    date_of_interest DATETIME NOT NULL, 
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (buyer_id),
    FOREIGN KEY (event_id) REFERENCES festival_event(event_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION
);

DROP TABLE IF EXISTS ticket_transaction;
CREATE TABLE ticket_transaction (
    transaction_id INT AUTO_INCREMENT,
    new_attendee_id INT NULL,        
    seller_id INT NULL,       
    IAN_number BIGINT NULL,   
    transaction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    status VARCHAR(50) DEFAULT 'Completed', 
    PRIMARY KEY (transaction_id),
    FOREIGN KEY (IAN_number) REFERENCES ticket(IAN_number)
        ON DELETE SET NULL ON UPDATE CASCADE
);

DROP TABLE IF EXISTS genre;
CREATE TABLE genre (
    genre_id INT NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL,
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (genre_id),
    UNIQUE(genre_name)
);

DROP TABLE IF EXISTS subgenre;
CREATE TABLE subgenre (
    subgenre_id INT NOT NULL AUTO_INCREMENT,
    genre_id INT NOT NULL,
    subgenre_name VARCHAR(50) NOT NULL UNIQUE,
    descr VARCHAR(500),
    img VARCHAR(100) NOT NULL CHECK (img like 'https://%'),
    PRIMARY KEY (subgenre_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    UNIQUE (genre_id, subgenre_name)
);

DROP TABLE IF EXISTS artist_subgenre;
CREATE TABLE artist_subgenre (
    artist_id  INT NOT NULL,
    subgenre_id INT NOT NULL,
    artist_subgenre_id INT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (artist_subgenre_id),
    FOREIGN KEY (subgenre_id) REFERENCES subgenre(subgenre_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
        ON DELETE RESTRICT ON UPDATE NO ACTION,
    UNIQUE(artist_id, subgenre_id)
);



