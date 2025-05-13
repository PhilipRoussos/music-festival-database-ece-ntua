USE festival_database;

DROP TRIGGER IF EXISTS performance_type_check;
DELIMITER $$
CREATE TRIGGER performance_type_check
BEFORE INSERT ON performance
FOR EACH ROW
BEGIN
    IF NEW.performance_type NOT IN ('warm up', 'headline', 'Special guest') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Performance Type';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS performance_type_update;
DELIMITER $$
CREATE TRIGGER performance_type_update
BEFORE UPDATE ON performance
FOR EACH ROW
BEGIN
    IF NEW.performance_type NOT IN ('warm up', 'headline', 'Special guest') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Performance Type';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS staff_specialty_check;
DELIMITER $$
CREATE TRIGGER staff_specialty_check
BEFORE INSERT ON staff
FOR EACH ROW
BEGIN
    IF NEW.specialty NOT IN ('technicians', 'security personnel', 'support staff') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Staff Type';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS staff_specialty_update;
DELIMITER $$
CREATE TRIGGER staff_specialty_update
BEFORE UPDATE ON staff
FOR EACH ROW
BEGIN
    IF NEW.specialty NOT IN ('technicians', 'security personnel', 'support staff') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Staff Type';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS equipment_type_check;
DELIMITER $$
CREATE TRIGGER equipment_type_check
BEFORE INSERT ON equipment
FOR EACH ROW
BEGIN
    IF NEW.equipment_type NOT IN ('speakers', 'lights', 'microphones', 'consoles', 'special effects') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Equipment Type';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS equipment_type_update;
DELIMITER $$
CREATE TRIGGER equipment_type_update
BEFORE UPDATE ON equipment
FOR EACH ROW
BEGIN
    IF NEW.equipment_type NOT IN ('speakers', 'lights', 'microphones', 'consoles', 'special effects') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Equipment Type';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ticket_type_check;
DELIMITER $$
CREATE TRIGGER ticket_type_check
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
    IF NEW.ticket_type NOT IN ('general admission', 'VIP', 'backstage') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Ticket Type';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ticket_type_update;
DELIMITER $$
CREATE TRIGGER ticket_type_update
BEFORE UPDATE ON ticket
FOR EACH ROW
BEGIN
    IF NEW.ticket_type NOT IN ('general admission', 'VIP', 'backstage') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Ticket Type';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS purchase_method_check;
DELIMITER $$
CREATE TRIGGER purchase_method_check
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
    IF NEW.purchase_method NOT IN ('credit card', 'debit card', 'bank deposit') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Purchase Method';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS purchase_method_update;
DELIMITER $$
CREATE TRIGGER purchase_method_update
BEFORE UPDATE ON ticket
FOR EACH ROW
BEGIN
    IF NEW.purchase_method NOT IN ('credit card', 'debit card', 'bank deposit') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Purchase Method';
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS after_seller_insert_update_ticket;
DELIMITER $$
CREATE TRIGGER after_seller_insert_update_ticket
AFTER INSERT ON seller
FOR EACH ROW
BEGIN
    UPDATE ticket
    SET resale_available = TRUE,
          activated = FALSE
    WHERE IAN_number = NEW.IAN_number; 
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS ProcessAllResaleTransactions;
DELIMITER $$
CREATE PROCEDURE ProcessAllResaleTransactions()
BEGIN

    DECLARE v_seller_id INT;
    DECLARE v_ticket_IAN BIGINT;
    DECLARE v_event_id INT;
    DECLARE v_ticket_type VARCHAR(100);
    DECLARE v_seller_attendee_id INT;

    DECLARE v_buyer_id INT;
    DECLARE v_buyer_name VARCHAR(100);
    DECLARE v_buyer_age INT;
    DECLARE v_buyer_contact_info VARCHAR(100);
    DECLARE v_buyer_address VARCHAR(100);
    DECLARE v_buyer_city VARCHAR(100);
    DECLARE v_buyer_country VARCHAR(100);
    DECLARE v_buyer_descr VARCHAR(500);
    DECLARE v_buyer_img VARCHAR(100);

    DECLARE v_new_attendee_id INT;

    DECLARE done INT DEFAULT FALSE;
    DECLARE transactions_made INT DEFAULT 0;

    DECLARE seller_cursor CURSOR FOR
        SELECT s.seller_id, s.IAN_number, t.event_id, t.ticket_type, t.attendee_id
        FROM seller s
        JOIN ticket t ON s.IAN_number = t.IAN_number
        WHERE t.resale_available = TRUE AND t.activated = FALSE
        ORDER BY s.date_of_interest ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN seller_cursor;

    seller_loop: LOOP
        FETCH seller_cursor INTO v_seller_id, v_ticket_IAN, v_event_id, v_ticket_type, v_seller_attendee_id;

        IF done THEN
            LEAVE seller_loop;
        END IF;

        SET v_buyer_id = NULL;

        SELECT b.buyer_id, b.buyer_name, b.age, b.contact_info, b.buyer_address, b.city, b.country, b.descr, b.img
        INTO v_buyer_id, v_buyer_name, v_buyer_age, v_buyer_contact_info, v_buyer_address, v_buyer_city, v_buyer_country, v_buyer_descr, v_buyer_img
        FROM buyer b
        WHERE b.event_id = v_event_id 
          AND (b.ticket_type IS NULL OR b.ticket_type = v_ticket_type)
        ORDER BY b.date_of_interest ASC
        LIMIT 1;

        
        IF v_buyer_id IS NOT NULL THEN
            
            BEGIN

                INSERT INTO attendee (attendee_name, age, contact_info, attendee_address, city, country, descr, img)
                VALUES (v_buyer_name, v_buyer_age, v_buyer_contact_info, v_buyer_address, v_buyer_city, v_buyer_country, v_buyer_descr, v_buyer_img);
                SET v_new_attendee_id = LAST_INSERT_ID();

                UPDATE ticket
                SET attendee_id = v_new_attendee_id,
                    resale_available = FALSE,
                    owner_info = CONCAT('Resold via queue from Attendee ID: ', v_seller_attendee_id, ' to new Attendee ID: ', v_new_attendee_id, ' (', v_buyer_name, ')')
                WHERE IAN_number = v_ticket_IAN;

                INSERT INTO ticket_transaction (new_attendee_id, seller_id, IAN_number, status)
                VALUES (v_new_attendee_id, v_seller_id, v_ticket_IAN, 'Completed');

                DELETE FROM buyer WHERE buyer_id = v_buyer_id;

                DELETE FROM seller WHERE seller_id = v_seller_id;

                COMMIT;
                SET transactions_made = transactions_made + 1;

            END;

        END IF;

    END LOOP seller_loop;
    CLOSE seller_cursor;

    SELECT CONCAT(transactions_made, ' resale transaction(s) processed') AS status_message;

END $$
DELIMITER ;


DROP FUNCTION IF EXISTS check_vip;
DELIMITER $$
CREATE FUNCTION check_vip(ev_id INT) RETURNS INT READS SQL DATA
BEGIN
    DECLARE current_vip INT;
    DECLARE scene_cap INT;
    DECLARE max_vip INT;

    SELECT COUNT(*) INTO current_vip
    FROM ticket
    WHERE event_id = ev_id AND ticket_type = 'VIP';

    SELECT s.capacity INTO scene_cap
    FROM festival_event fest_ev
    JOIN scene s ON fest_ev.scene_id = s.scene_id
    WHERE fest_ev.event_id = ev_id;

    IF scene_cap IS NULL OR scene_cap <= 0 THEN
        RETURN 0;
    END IF;
    SET max_vip = CEIL(scene_cap * 0.10);

    IF current_vip >= max_vip THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS vip_limit_insert;
DELIMITER $$
CREATE TRIGGER vip_limit_insert
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
    IF NEW.ticket_type = 'VIP' THEN
        IF check_vip(NEW.event_id) = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'VIP ticket limit reached for this event';
        END IF;
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS vip_limit_update;
DELIMITER $$
CREATE TRIGGER vip_limit_update
BEFORE UPDATE ON ticket
FOR EACH ROW
BEGIN
    IF NEW.ticket_type = 'VIP' AND OLD.ticket_type != 'VIP' THEN
        IF check_vip(NEW.event_id) = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'VIP ticket limit reached for this event';
        END IF;
    END IF;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS CheckConsecutiveYears;
DELIMITER $$
CREATE FUNCTION CheckConsecutiveYears(
    p_performer_id INT,
    p_is_band BOOLEAN,
    p_festival_year YEAR
) RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE participation_y1 BOOLEAN DEFAULT FALSE;
    DECLARE participation_y2 BOOLEAN DEFAULT FALSE;
    DECLARE participation_y3 BOOLEAN DEFAULT FALSE;
    DECLARE year_check_1 YEAR(4);
    DECLARE year_check_2 YEAR(4);
    DECLARE year_check_3 YEAR(4);

    SET year_check_1 = p_festival_year - 1;
    SET year_check_2 = p_festival_year - 2;
    SET year_check_3 = p_festival_year - 3;

    SELECT EXISTS (
        SELECT 1
        FROM performance p
        JOIN festival_event fe ON p.event_id = fe.event_id
        WHERE fe.festival_year = year_check_1
        AND ((p_is_band = FALSE AND p.artist_id = p_performer_id) OR (p_is_band = TRUE AND p.band_id = p_performer_id))
        LIMIT 1
    ) INTO participation_y1;

    SELECT EXISTS (
        SELECT 1
        FROM performance p
        JOIN festival_event fe ON p.event_id = fe.event_id
        WHERE fe.festival_year = year_check_2
        AND ((p_is_band = FALSE AND p.artist_id = p_performer_id) OR (p_is_band = TRUE AND p.band_id = p_performer_id))
        LIMIT 1
    ) INTO participation_y2;

    SELECT EXISTS (
        SELECT 1
        FROM performance p
        JOIN festival_event fe ON p.event_id = fe.event_id
        WHERE fe.festival_year = year_check_3
        AND ((p_is_band = FALSE AND p.artist_id = p_performer_id) OR (p_is_band = TRUE AND p.band_id = p_performer_id))
        LIMIT 1
    ) INTO participation_y3;

    RETURN (participation_y1 AND participation_y2 AND participation_y3);
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS CheckSimultaneousPerformance;
DELIMITER $$
CREATE FUNCTION CheckSimultaneousPerformance(
    p_performer_id INT,
    p_is_band BOOLEAN,
    p_start_datetime DATETIME,
    p_duration INT,
    p_scene_id INT,
    p_performance_id_to_exclude INT
) RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE conflict_exists BOOLEAN DEFAULT FALSE;
    DECLARE new_start_datetime DATETIME;
    DECLARE new_end_datetime DATETIME;
    DECLARE check_date DATE;

    SET new_start_datetime = p_start_datetime;
    SET new_end_datetime = DATE_ADD(new_start_datetime, INTERVAL p_duration MINUTE);
    SET check_date = DATE(new_start_datetime);

    SELECT EXISTS (
        SELECT 1
        FROM performance p
        JOIN festival_event fe ON p.event_id = fe.event_id
        WHERE
            (p_performance_id_to_exclude IS NULL OR p.performance_id <> p_performance_id_to_exclude)
            AND DATE(p.start_datetime) = check_date
            AND fe.scene_id <> p_scene_id
            AND (
                (p_is_band = FALSE AND p.artist_id = p_performer_id) OR
                (p_is_band = TRUE AND p.band_id = p_performer_id)
            )
            AND (
                new_start_datetime < DATE_ADD(p.start_datetime, INTERVAL p.duration MINUTE)
                AND
                p.start_datetime < new_end_datetime
            )
        LIMIT 1
    ) INTO conflict_exists;

    RETURN conflict_exists;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS performance_enforce_rules_before_insert;
DELIMITER $$
CREATE TRIGGER performance_enforce_rules_before_insert
BEFORE INSERT ON performance
FOR EACH ROW
BEGIN
    DECLARE v_is_band BOOLEAN;
    DECLARE v_performer_id INT;
    DECLARE v_festival_year YEAR;
    DECLARE v_scene_id INT;

    SELECT fe.festival_year, fe.scene_id
    INTO v_festival_year, v_scene_id
    FROM festival_event fe
    WHERE fe.event_id = NEW.event_id;

    IF CheckConsecutiveYears(v_performer_id, v_is_band, v_festival_year) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participation limit exceeded';
    END IF;

    IF CheckSimultaneousPerformance(
            v_performer_id,
            v_is_band,
            NEW.start_datetime,
            NEW.duration,
            v_scene_id,
            NULL
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Scheduling conflict';
    END IF;

END $$
DELIMITER ;

DROP TRIGGER IF EXISTS performance_enforce_rules_before_update;
DELIMITER $$
CREATE TRIGGER performance_enforce_rules_before_update
BEFORE UPDATE ON performance
FOR EACH ROW
BEGIN
    DECLARE v_is_band BOOLEAN;
    DECLARE v_performer_id INT;
    DECLARE v_festival_year YEAR;
    DECLARE v_scene_id INT;

    SELECT fe.festival_year, fe.scene_id
    INTO v_festival_year, v_scene_id
    FROM festival_event fe
    WHERE fe.event_id = NEW.event_id;

    IF CheckConsecutiveYears(v_performer_id, v_is_band, v_festival_year) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Participation limit exceeded';
    END IF;

    IF CheckSimultaneousPerformance(
            v_performer_id,
            v_is_band,
            NEW.start_datetime,
            NEW.duration,
            v_scene_id,
            NEW.performance_id
        ) THEN
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Scheduling conflict';
    END IF;

END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS CheckStaffRequirements;
DELIMITER $$
CREATE PROCEDURE CheckStaffRequirements()
BEGIN
  
  SELECT 
    se.event_id,
    SUM(st.specialty = 'security personnel')     AS have_security,
    CEIL(0.05 * s.capacity)                      AS need_security,
    SUM(st.specialty = 'support staff')          AS have_support,
    CEIL(0.02 * s.capacity)                      AS need_support
  FROM staff_event AS se
  JOIN staff        AS st    USING(staff_id)
  JOIN festival_event AS fe  USING(event_id)
  JOIN scene        AS s     ON fe.scene_id = s.scene_id
  GROUP BY se.event_id
  HAVING have_security < need_security
      OR have_support  < need_support;
END$$
DELIMITER ;




DROP TRIGGER IF EXISTS staff_event_check_before_delete;
DELIMITER $$
CREATE TRIGGER staff_event_check_before_delete
BEFORE DELETE ON staff_event
FOR EACH ROW
BEGIN   
 
  DECLARE old_spec   VARCHAR(100);
  DECLARE cap        INT;
  DECLARE req_sec    INT;
  DECLARE req_sup    INT;
  DECLARE cur_sec    INT;
  DECLARE cur_sup    INT;

  SELECT specialty INTO old_spec
    FROM staff
   WHERE staff_id = OLD.staff_id;

 
  SELECT s.capacity
    INTO cap
    FROM festival_event fe
    JOIN scene          s USING(scene_id)
   WHERE fe.event_id = OLD.event_id;


  SET req_sec = CEIL(0.05 * cap),
      req_sup = CEIL(0.02 * cap);

  SELECT COUNT(*)
    INTO cur_sec
    FROM staff_event se
    JOIN staff       st USING(staff_id)
   WHERE se.event_id = OLD.event_id
     AND st.specialty = 'security personnel';

 
  SELECT COUNT(*)
    INTO cur_sup
    FROM staff_event se
    JOIN staff       st USING(staff_id)
   WHERE se.event_id = OLD.event_id
     AND st.specialty = 'support staff';

  
  IF old_spec = 'security personnel' AND (cur_sec - 1) < req_sec THEN
      SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Cannot remove security: would fall below 5% requirement';
  END IF;

  
  IF old_spec = 'support staff' AND (cur_sup - 1) < req_sup THEN
      SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Cannot remove support staff: would fall below 2% requirement';
  END IF;
END$$
DELIMITER ;



DROP TRIGGER IF EXISTS staff_event_check_before_update;
DELIMITER $$
CREATE TRIGGER staff_event_check_before_update
BEFORE UPDATE ON staff_event
FOR EACH ROW

update_trigger_block: BEGIN

  
  DECLARE old_spec   VARCHAR(100);
  DECLARE new_spec   VARCHAR(100);
  DECLARE cap        INT;
  DECLARE req_sec    INT;
  DECLARE req_sup    INT;
  DECLARE cur_sec    INT;
  DECLARE cur_sup    INT;

  
  SELECT specialty INTO old_spec FROM staff WHERE staff_id = OLD.staff_id;
 
  SELECT specialty INTO new_spec FROM staff WHERE staff_id = NEW.staff_id;

 
  IF old_spec NOT IN ('security personnel','support staff')
     OR new_spec = old_spec THEN
         LEAVE update_trigger_block;
  END IF;

 
  SELECT s.capacity
    INTO cap
    FROM festival_event fe
    JOIN scene          s USING(scene_id)
   WHERE fe.event_id = OLD.event_id; 


  SET req_sec = CEIL(0.05 * cap),
      req_sup = CEIL(0.02 * cap);

  
  SELECT COUNT(*)
    INTO cur_sec
    FROM staff_event se
    JOIN staff       st USING(staff_id)
   WHERE se.event_id = OLD.event_id
     AND st.specialty = 'security personnel';

  
  SELECT COUNT(*)
    INTO cur_sup
    FROM staff_event se
    JOIN staff       st USING(staff_id)
   WHERE se.event_id = OLD.event_id
     AND st.specialty = 'support staff';


  IF old_spec = 'security personnel' AND (cur_sec - 1) < req_sec THEN
      SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Cannot update assignment: security staff would fall below 5% requirement';
  END IF;

 
  IF old_spec = 'support staff' AND (cur_sup - 1) < req_sup THEN
      SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Cannot update assignment: support staff would fall below 2% requirement';
  END IF;
END$$ 
DELIMITER ;

DROP TRIGGER IF EXISTS rating_activated_ticket_check;
DELIMITER $$
CREATE TRIGGER rating_activated_ticket_check
BEFORE INSERT ON rating
FOR EACH ROW
BEGIN
    DECLARE v_ticket_is_activated_for_performance BOOLEAN DEFAULT FALSE;

    SELECT EXISTS (
        SELECT 1
        FROM ticket t
        JOIN performance p ON t.event_id = p.event_id
        WHERE t.IAN_number = NEW.IAN_number
          AND p.performance_id = NEW.performance_id
          AND t.activated = TRUE
    ) INTO v_ticket_is_activated_for_performance;

    IF NOT v_ticket_is_activated_for_performance THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot insert Rating invalid performance or not activated ticket type';
    END IF;
END $$
DELIMITER ;
