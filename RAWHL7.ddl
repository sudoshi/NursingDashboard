-- =========================================================
-- HL7 Schema: Comprehensive ADT/ORM Tables
-- =========================================================

-- ---------------------------------------------------------
-- 1. HL7_RAW_MESSAGES
--    Stores the entire HL7 message text plus key metadata.
-- ---------------------------------------------------------
CREATE TABLE HL7_RAW_MESSAGES (
    hl7_raw_message_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    message_control_id      VARCHAR(50)     NOT NULL,   -- MSH-10
    message_type            VARCHAR(10)     NOT NULL,   -- MSH-9.1 (e.g., ADT, ORM, ORU, etc.)
    event_type              VARCHAR(10)     NOT NULL,   -- MSH-9.2 (e.g., A01, A02, O01, etc.)
    sending_application     VARCHAR(100)    NOT NULL,   -- MSH-3
    sending_facility        VARCHAR(100)    NOT NULL,   -- MSH-4
    receiving_application   VARCHAR(100)    NOT NULL,   -- MSH-5
    receiving_facility      VARCHAR(100)    NOT NULL,   -- MSH-6
    version_id              VARCHAR(10)     NOT NULL,   -- MSH-12 (e.g. 2.3, 2.4, 2.5.1)
    creation_datetime       DATETIME        NOT NULL,   -- MSH-7
    raw_message             TEXT            NOT NULL    -- Full text of the HL7 message
);

CREATE INDEX idx_msg_ctrl ON HL7_RAW_MESSAGES (message_control_id);
CREATE INDEX idx_msg_type  ON HL7_RAW_MESSAGES (message_type, event_type);
CREATE INDEX idx_date      ON HL7_RAW_MESSAGES (creation_datetime);

-- ---------------------------------------------------------
-- 2. HL7_MSH
--    Stores the parsed MSH (Message Header) segment.
-- ---------------------------------------------------------
CREATE TABLE HL7_MSH (
    hl7_msh_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT          NOT NULL,  
    field_separator         VARCHAR(1)      NOT NULL,  
    encoding_characters     VARCHAR(4)      NOT NULL,  
    sending_application     VARCHAR(100)    NOT NULL,  
    sending_facility        VARCHAR(100)    NOT NULL,  
    receiving_application   VARCHAR(100)    NOT NULL,  
    receiving_facility      VARCHAR(100)    NOT NULL,  
    message_datetime        DATETIME        NOT NULL,  
    security                VARCHAR(50)     NULL,      
    message_type            VARCHAR(10)     NOT NULL,  
    message_control_id      VARCHAR(50)     NOT NULL,  
    processing_id           VARCHAR(5)      NULL,      
    version_id              VARCHAR(10)     NOT NULL,  
    sequence_number         VARCHAR(10)     NULL,      
    continuation_pointer    VARCHAR(50)     NULL,      
    accept_ack_type         VARCHAR(5)      NULL,      
    app_ack_type            VARCHAR(5)      NULL,      
    country_code            VARCHAR(5)      NULL,      
    character_set           VARCHAR(10)     NULL,      
    principal_language      VARCHAR(10)     NULL,      
    FOREIGN KEY (hl7_raw_message_id) 
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_msh_msg_ctrl ON HL7_MSH (message_control_id);

-- ---------------------------------------------------------
-- 3. HL7_PID
--    Stores the PID (Patient Identification) segment.
-- ---------------------------------------------------------
CREATE TABLE HL7_PID (
    hl7_pid_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT         NOT NULL,  
    set_id                  VARCHAR(5)     NOT NULL,  
    patient_id              VARCHAR(50)    NULL,      
    patient_identifier_list VARCHAR(200)   NULL,      
    alternate_patient_id    VARCHAR(50)    NULL,      
    patient_name            VARCHAR(200)   NULL,      
    mother_maiden_name      VARCHAR(100)   NULL,      
    dob                     DATE           NULL,      
    sex                     VARCHAR(1)     NULL,      
    patient_alias           VARCHAR(100)   NULL,      
    race                    VARCHAR(100)   NULL,      
    address                 VARCHAR(200)   NULL,      
    phone_number_home       VARCHAR(50)    NULL,      
    phone_number_business   VARCHAR(50)    NULL,      
    marital_status          VARCHAR(5)     NULL,      
    ssn_number              VARCHAR(20)    NULL,      
    driver_license_number   VARCHAR(50)    NULL,      
    citizenship             VARCHAR(50)    NULL,      
    birth_place             VARCHAR(100)   NULL,      
    ethnic_group            VARCHAR(50)    NULL,      
    foreign_key_1           VARCHAR(50)    NULL,      
    foreign_key_2           VARCHAR(50)    NULL,
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_pid_patient_id ON HL7_PID (patient_id);

-- ---------------------------------------------------------
-- 4. HL7_PV1
--    Stores the PV1 (Patient Visit) segment.
-- ---------------------------------------------------------
CREATE TABLE HL7_PV1 (
    hl7_pv1_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT       NOT NULL,  
    set_id                  VARCHAR(5)   NOT NULL,  
    patient_class           VARCHAR(5)   NULL,      
    assigned_patient_location VARCHAR(100) NULL,    
    admission_type          VARCHAR(5)   NULL,      
    preadmit_number         VARCHAR(50)  NULL,      
    prior_patient_location  VARCHAR(100) NULL,      
    attending_doctor        VARCHAR(200) NULL,      
    referring_doctor        VARCHAR(200) NULL,      
    consulting_doctor       VARCHAR(200) NULL,      
    hospital_service        VARCHAR(50)  NULL,      
    bed_status              VARCHAR(5)   NULL,      
    visit_number            VARCHAR(50)  NULL,      
    financial_class         VARCHAR(50)  NULL,      
    charge_price_indicator  VARCHAR(5)   NULL,      
    courtest_code           VARCHAR(5)   NULL,      
    credit_rating           VARCHAR(5)   NULL,      
    account_status          VARCHAR(10)  NULL,      
    foreign_key_1           VARCHAR(50)  NULL,
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_pv1_visit_number ON HL7_PV1 (visit_number);

-- ---------------------------------------------------------
-- 5. HL7_NK1
--    Stores the NK1 (Next of Kin) segment.
-- ---------------------------------------------------------
CREATE TABLE HL7_NK1 (
    hl7_nk1_id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id        BIGINT      NOT NULL,  
    set_id                    VARCHAR(5)  NOT NULL,  
    name                      VARCHAR(200) NULL,     
    relationship              VARCHAR(50)  NULL,     
    address                   VARCHAR(255) NULL,     
    phone_number              VARCHAR(50)  NULL,     
    business_phone_number     VARCHAR(50)  NULL,     
    contact_role              VARCHAR(50)  NULL,     
    start_date                DATE         NULL,     
    end_date                  DATE         NULL,     
    next_of_kin_associated_parties_job_title VARCHAR(100) NULL,
    comment                   VARCHAR(255) NULL,     
    contact_person_s_name     VARCHAR(200) NULL,     
    contact_person_phone      VARCHAR(50)  NULL,     
    contact_person_address    VARCHAR(255) NULL,     
    associated_parties_identifiers VARCHAR(255) NULL,
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_nk1_name ON HL7_NK1 (name);

-- ---------------------------------------------------------
-- 6. HL7_DG1
--    Stores the DG1 (Diagnosis) segment.
-- ---------------------------------------------------------
CREATE TABLE HL7_DG1 (
    hl7_dg1_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT      NOT NULL,   
    set_id                  VARCHAR(5)  NOT NULL,   
    diagnosis_coding_method VARCHAR(10) NULL,       
    diagnosis_code          VARCHAR(50) NULL,       
    diagnosis_description   VARCHAR(255) NULL,      
    diagnosis_date_time     DATETIME     NULL,      
    diagnosis_type          VARCHAR(5)   NULL,      
    major_diagnostic_category VARCHAR(50) NULL,     
    diagnostic_related_group VARCHAR(50) NULL,      
    drg_approval_indicator  VARCHAR(5)   NULL,      
    principal_diagnosis_indicator VARCHAR(5) NULL,  
    foreign_key_1           VARCHAR(50)  NULL,      
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_dg1_code ON HL7_DG1 (diagnosis_code);

-- ---------------------------------------------------------
-- 7. HL7_AL1
--    Stores the AL1 (Allergies) segment.
-- ---------------------------------------------------------
CREATE TABLE HL7_AL1 (
    hl7_al1_id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id     BIGINT       NOT NULL, 
    set_id                 VARCHAR(5)   NOT NULL, 
    allergen_type_code     VARCHAR(50)  NULL,     
    allergen_code          VARCHAR(50)  NULL,     
    allergen_description   VARCHAR(255) NULL,     
    allergy_severity_code  VARCHAR(50)  NULL,     
    allergy_reaction_code  VARCHAR(255) NULL,     
    identification_date    DATETIME     NULL,     
    comment                VARCHAR(255) NULL,
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_al1_allergen_code ON HL7_AL1 (allergen_code);

-- ---------------------------------------------------------
-- 8. HL7_GT1
--    Stores the GT1 (Guarantor) segment.
-- ---------------------------------------------------------
CREATE TABLE HL7_GT1 (
    hl7_gt1_id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id     BIGINT       NOT NULL,  
    set_id                 VARCHAR(5)   NOT NULL,  
    guarantor_number       VARCHAR(50)  NULL,      
    guarantor_name         VARCHAR(200) NULL,      
    guarantor_spouse_name  VARCHAR(200) NULL,      
    address                VARCHAR(255) NULL,      
    phone_home             VARCHAR(50)  NULL,      
    phone_business         VARCHAR(50)  NULL,      
    date_of_birth          DATE         NULL,      
    sex                    VARCHAR(1)   NULL,      
    guarantor_type         VARCHAR(50)  NULL,      
    relationship_to_patient VARCHAR(50) NULL,      
    ssn_number             VARCHAR(20)  NULL,      
    begin_date             DATETIME     NULL,      
    end_date               DATETIME     NULL,      
    employer_name          VARCHAR(200) NULL,      
    employer_address       VARCHAR(255) NULL,      
    employer_phone         VARCHAR(50)  NULL,      
    foreign_key_1          VARCHAR(50)  NULL,
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_gt1_guarantor_number ON HL7_GT1 (guarantor_number);

-- ---------------------------------------------------------
-- 9. HL7_ORC
--    Stores the ORC (Common Order) segment (often in ORM/ORU).
-- ---------------------------------------------------------
CREATE TABLE HL7_ORC (
    hl7_orc_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT       NOT NULL,  
    order_control           VARCHAR(5)   NOT NULL,  
    placer_order_number     VARCHAR(50)  NULL,      
    filler_order_number     VARCHAR(50)  NULL,      
    placer_group_number     VARCHAR(50)  NULL,      
    order_status            VARCHAR(5)   NULL,      
    response_flag           VARCHAR(5)   NULL,      
    quantity_timing         VARCHAR(100) NULL,      
    parent                  VARCHAR(100) NULL,      
    datetime_of_transaction DATETIME     NULL,      
    entered_by              VARCHAR(200) NULL,      
    verified_by             VARCHAR(200) NULL,      
    ordering_provider       VARCHAR(200) NULL,      
    enterer_location        VARCHAR(100) NULL,      
    callback_phone_number   VARCHAR(100) NULL,      
    order_effective_date    DATETIME     NULL,      
    order_control_code_reason VARCHAR(200) NULL,    
    entering_organization   VARCHAR(200) NULL,      
    entering_device         VARCHAR(200) NULL,      
    action_by               VARCHAR(200) NULL,      
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_orc_placer_order ON HL7_ORC (placer_order_number);
CREATE INDEX idx_orc_filler_order ON HL7_ORC (filler_order_number);

-- ---------------------------------------------------------
-- 10. HL7_OBR
--     Stores the OBR (Observation Request) segment (ORM/ORU).
-- ---------------------------------------------------------
CREATE TABLE HL7_OBR (
    hl7_obr_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT        NOT NULL, 
    set_id                  VARCHAR(5)    NOT NULL, 
    placer_order_number     VARCHAR(50)   NULL,     
    filler_order_number     VARCHAR(50)   NULL,     
    universal_service_id    VARCHAR(200)  NULL,     
    priority                VARCHAR(5)    NULL,     
    requested_datetime      DATETIME      NULL,     
    observation_datetime    DATETIME      NULL,     
    observation_end_datetime DATETIME     NULL,     
    collection_volume       VARCHAR(50)   NULL,     
    collector_identifier    VARCHAR(200)  NULL,     
    speciment_action_code   VARCHAR(5)    NULL,     
    danger_code             VARCHAR(50)   NULL,     
    relevant_clinical_info  VARCHAR(255)  NULL,     
    specimen_received_datetime DATETIME   NULL,     
    specimen_source         VARCHAR(255)  NULL,     
    ordering_provider       VARCHAR(200)  NULL,     
    order_callback_phone_number VARCHAR(50) NULL,   
    placer_field_1          VARCHAR(50)   NULL,     
    placer_field_2          VARCHAR(50)   NULL,     
    filler_field_1          VARCHAR(50)   NULL,     
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_obr_placer_order ON HL7_OBR (placer_order_number);
CREATE INDEX idx_obr_filler_order ON HL7_OBR (filler_order_number);

-- ---------------------------------------------------------
-- 11. HL7_OBX
--     Stores the OBX (Observation/Result) segment (ORM/ORU).
-- ---------------------------------------------------------
CREATE TABLE HL7_OBX (
    hl7_obx_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT        NOT NULL,   
    set_id                  VARCHAR(5)    NOT NULL,   
    value_type              VARCHAR(10)   NOT NULL,   
    observation_identifier  VARCHAR(100)  NOT NULL,   
    observation_sub_id      VARCHAR(50)   NULL,       
    observation_value       TEXT          NULL,       
    units                   VARCHAR(50)   NULL,       
    references_range        VARCHAR(50)   NULL,       
    abnormal_flags          VARCHAR(5)    NULL,       
    observation_result_status VARCHAR(5)  NULL,       
    observation_datetime    DATETIME      NULL,       
    producer_id             VARCHAR(100)  NULL,       
    responsible_observer    VARCHAR(100)  NULL,       
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);

CREATE INDEX idx_obx_identifier ON HL7_OBX (observation_identifier);

-- ---------------------------------------------------------
-- 12. (Optional) HL7_PD1
--     Stores additional demographic info (PD1 segment).
--     Uncomment if needed.
-- ---------------------------------------------------------
/*
CREATE TABLE HL7_PD1 (
    hl7_pd1_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    hl7_raw_message_id      BIGINT      NOT NULL, 
    living_dependency       VARCHAR(50) NULL,     
    living_arrangement      VARCHAR(50) NULL,     
    primary_facility        VARCHAR(255) NULL,    
    primary_care_provider   VARCHAR(255) NULL,    
    student_indicator       VARCHAR(10) NULL,      
    handicap                VARCHAR(50) NULL,      
    living_will_code        VARCHAR(50) NULL,      
    organ_donor_code        VARCHAR(50) NULL,      
    separate_bill           VARCHAR(5)  NULL,      
    FOREIGN KEY (hl7_raw_message_id)
       REFERENCES HL7_RAW_MESSAGES (hl7_raw_message_id)
);
*/

-- =========================================================
-- END OF HL7 SCHEMA
-- =========================================================
