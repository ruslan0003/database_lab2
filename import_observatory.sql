-- ----------------------------------------------------------------------------
-- MySQL Workbench Migration
-- Migrated Schemata: observatory_db
-- Source Schemata: observatory
-- Created: Thu Jun 13 10:37:18 2024
-- Workbench Version: 8.0.36
-- ----------------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Schema observatory_db
-- ----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS `observatory_db` ;
CREATE SCHEMA IF NOT EXISTS `observatory_db` ;

-- ----------------------------------------------------------------------------
-- Table observatory_db.natural_objects
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `observatory_db`.`natural_objects` (
  `id` INT(4) NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(45) NULL DEFAULT NULL,
  `galaxy` VARCHAR(45) NULL DEFAULT NULL,
  `accuracy` DECIMAL(5,2) NULL DEFAULT NULL,
  `light_flow` DECIMAL(10,0) NULL DEFAULT NULL,
  `related_objects` VARCHAR(120) NULL DEFAULT NULL,
  `notes` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- ----------------------------------------------------------------------------
-- Table observatory_db.objects
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `observatory_db`.`objects` (
  `id` INT(4) NOT NULL,
  `type` VARCHAR(45) NULL DEFAULT NULL,
  `accuracy` DECIMAL(5,2) NULL DEFAULT NULL,
  `amount` INT(4) NULL DEFAULT NULL,
  `time` TIME NULL DEFAULT NULL,
  `date` DATE NULL DEFAULT NULL,
  `notes` TEXT NULL DEFAULT NULL,
  UNIQUE INDEX `id_UNIQUE` (`id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- ----------------------------------------------------------------------------
-- Table observatory_db.position
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `observatory_db`.`position` (
  `id` INT(4) NOT NULL AUTO_INCREMENT,
  `earth_position` DECIMAL(9,6) NULL DEFAULT NULL,
  `sun_position` DECIMAL(9,6) NULL DEFAULT NULL,
  `moon_position` DECIMAL(9,6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idPosition_UNIQUE` (`id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- ----------------------------------------------------------------------------
-- Table observatory_db.sector
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `observatory_db`.`sector` (
  `id` INT(4) NOT NULL AUTO_INCREMENT,
  `coordinates` DECIMAL(9,6) NULL DEFAULT NULL,
  `luminous_intensity` INT(5) NULL DEFAULT NULL,
  `foreign_objects` INT(4) NULL DEFAULT NULL,
  `sky_objects` INT(4) NULL DEFAULT NULL,
  `undefined_objects` INT(4) NULL DEFAULT NULL,
  `specified_objects` INT(4) NULL DEFAULT NULL,
  `notes` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idSector_UNIQUE` (`id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- ----------------------------------------------------------------------------
-- Table observatory_db.events
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `observatory_db`.`events` (
  `id` INT(4) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NULL DEFAULT NULL,
  `description` TEXT NULL DEFAULT NULL,
  `date` DATE NULL DEFAULT NULL,
  `time` TIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC),
  CONSTRAINT `natural_object_id`
    FOREIGN KEY (`id`)
    REFERENCES `observatory_db`.`natural_objects` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `object_id`
    FOREIGN KEY (`id`)
    REFERENCES `observatory_db`.`objects` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `position_id`
    FOREIGN KEY (`id`)
    REFERENCES `observatory_db`.`position` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `sector_id`
    FOREIGN KEY (`id`)
    REFERENCES `observatory_db`.`sector` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;

-- ----------------------------------------------------------------------------
-- Routine observatory_db.joinTwoTables
-- ----------------------------------------------------------------------------
DELIMITER $$

DELIMITER $$
USE `observatory_db`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `joinTwoTables`(Table1 nvarchar(50), Table2 nvarchar(50))
BEGIN
	DECLARE query nvarchar(100);
    SET @query = CONCAT('SELECT * FROM ', table1, ' JOIN ', table2, ' ON ', table1, '.id = ', table2, '.', table1, '_id');
    PREPARE stmt FROM @joinQuery;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------------------------------------------------------
-- Trigger
-- ----------------------------------------------------------------------------

CREATE DEFINER=`root`@`localhost` TRIGGER `observatory_db`.`objects_AFTER_UPDATE` AFTER UPDATE ON `objects` FOR EACH ROW
BEGIN
 IF NOT EXISTS (SELECT * FROM observatory_db.columns 
                   WHERE table_name = 'objects' AND column_name = 'date_update') THEN
        -- Если столбец отсутствует, добавляем его командой ALTER TABLE
        ALTER TABLE Objects
        ADD COLUMN date_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
    END IF;
    -- Записываем текущую дату и время в столбец date_update
    UPDATE Objects 
    SET date_update = CURRENT_TIMESTAMP
    WHERE id = NEW.id;
END