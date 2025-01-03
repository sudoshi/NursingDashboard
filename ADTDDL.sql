-- Create extension for UUID generation if using PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row Level Security
ALTER DATABASE CURRENT SET row_level_security = on;

-- Core Patient Tables
CREATE TABLE patient (
    patient_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mrn VARCHAR(50) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10),
    contact_phone VARCHAR(20),
    preferred_language VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_patient_mrn UNIQUE (mrn)
);

CREATE TABLE patient_visit (
    visit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patient(patient_id),
    visit_number VARCHAR(50) NOT NULL,
    admission_date TIMESTAMP WITH TIME ZONE NOT NULL,
    expected_discharge_date TIMESTAMP WITH TIME ZONE,
    actual_discharge_date TIMESTAMP WITH TIME ZONE,
    admission_source VARCHAR(50),
    admission_type VARCHAR(50),
    patient_class VARCHAR(50),
    hospital_service VARCHAR(50),
    visit_status VARCHAR(20) NOT NULL,
    previous_visit_id UUID REFERENCES patient_visit(visit_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_visit_number UNIQUE (visit_number)
);

CREATE TABLE nursing_unit (
    unit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_name VARCHAR(100) NOT NULL,
    unit_type VARCHAR(50) NOT NULL,
    floor_number INTEGER,
    total_beds INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_unit_name UNIQUE (unit_name)
);

CREATE TABLE patient_location (
    location_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES patient_visit(visit_id),
    unit_id UUID NOT NULL REFERENCES nursing_unit(unit_id),
    room VARCHAR(20) NOT NULL,
    bed VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE,
    previous_location_id UUID REFERENCES patient_location(location_id),
    is_current BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_location_status CHECK (status IN ('occupied', 'reserved', 'available', 'blocked')),
    CONSTRAINT chk_location_dates CHECK (end_datetime IS NULL OR end_datetime > start_datetime)
);

-- Clinical & Resource Tables
CREATE TABLE provider (
    provider_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    npi VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    provider_type VARCHAR(50) NOT NULL,
    specialty VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_provider_npi UNIQUE (npi)
);

CREATE TABLE clinical_team (
    team_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES patient_visit(visit_id),
    provider_id UUID NOT NULL REFERENCES provider(provider_id),
    role VARCHAR(50) NOT NULL,
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_team_dates CHECK (end_datetime IS NULL OR end_datetime > start_datetime)
);

CREATE TABLE "order" (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES patient_visit(visit_id),
    ordering_provider_id UUID NOT NULL REFERENCES provider(provider_id),
    order_type VARCHAR(50) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    start_datetime TIMESTAMP WITH TIME ZONE,
    end_datetime TIMESTAMP WITH TIME ZONE,
    priority VARCHAR(10) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_order_dates CHECK (
        (start_datetime IS NULL OR start_datetime >= order_datetime) AND
        (end_datetime IS NULL OR end_datetime >= start_datetime)
    )
);

CREATE TABLE order_detail (
    order_detail_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES "order"(order_id),
    detail_type VARCHAR(50) NOT NULL,
    detail_value TEXT,
    sequence_number INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Event & Status Tables
CREATE TABLE patient_status (
    status_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES patient_visit(visit_id),
    status_type VARCHAR(50) NOT NULL,
    status_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    status_reason TEXT,
    previous_status_id UUID REFERENCES patient_status(status_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clinical_event (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES patient_visit(visit_id),
    event_type VARCHAR(50) NOT NULL,
    event_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    severity VARCHAR(20),
    status VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE hl7_message (
    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_type VARCHAR(10) NOT NULL,
    message_event VARCHAR(10) NOT NULL,
    message_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    message_control_id VARCHAR(50) NOT NULL,
    sending_application VARCHAR(100),
    sending_facility VARCHAR(100),
    raw_message TEXT NOT NULL,
    processed_datetime TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_message_control_id UNIQUE (message_control_id)
);

-- Operational Metrics Tables
CREATE TABLE bed_census (
    census_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID NOT NULL REFERENCES nursing_unit(unit_id),
    census_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    total_beds INTEGER NOT NULL,
    occupied_beds INTEGER NOT NULL,
    available_beds INTEGER NOT NULL,
    pending_admissions INTEGER DEFAULT 0,
    pending_discharges INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_census_beds CHECK (
        occupied_beds >= 0 AND
        available_beds >= 0 AND
        total_beds = occupied_beds + available_beds
    )
);

CREATE TABLE length_of_stay (
    los_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID NOT NULL REFERENCES patient_visit(visit_id),
    calculation_date DATE NOT NULL,
    current_los_days NUMERIC(10,2) NOT NULL,
    expected_los_days NUMERIC(10,2),
    los_variance_days NUMERIC(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_los_days CHECK (current_los_days >= 0)
);

CREATE TABLE throughput_metrics (
    metric_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unit_id UUID NOT NULL REFERENCES nursing_unit(unit_id),
    metric_date DATE NOT NULL,
    admit_volume INTEGER DEFAULT 0,
    discharge_volume INTEGER DEFAULT 0,
    transfer_volume INTEGER DEFAULT 0,
    ed_holds INTEGER DEFAULT 0,
    or_holds INTEGER DEFAULT 0,
    average_clean_time NUMERIC(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_unit_date UNIQUE (unit_id, metric_date)
);

-- Create Indexes
CREATE INDEX idx_patient_visit_patient_id ON patient_visit(patient_id);
CREATE INDEX idx_patient_visit_status ON patient_visit(visit_status);
CREATE INDEX idx_patient_location_visit_current ON patient_location(visit_id, is_current);
CREATE INDEX idx_patient_location_unit ON patient_location(unit_id);
CREATE INDEX idx_clinical_team_visit ON clinical_team(visit_id);
CREATE INDEX idx_clinical_team_provider ON clinical_team(provider_id);
CREATE INDEX idx_order_visit ON "order"(visit_id);
CREATE INDEX idx_order_provider ON "order"(ordering_provider_id);
CREATE INDEX idx_order_datetime ON "order"(order_datetime);
CREATE INDEX idx_patient_status_visit ON patient_status(visit_id);
CREATE INDEX idx_patient_status_datetime ON patient_status(status_datetime);
CREATE INDEX idx_clinical_event_visit ON clinical_event(visit_id);
CREATE INDEX idx_clinical_event_datetime ON clinical_event(event_datetime);
CREATE INDEX idx_hl7_message_datetime ON hl7_message(message_datetime);
CREATE INDEX idx_bed_census_unit_datetime ON bed_census(unit_id, census_datetime);
CREATE INDEX idx_length_of_stay_visit ON length_of_stay(visit_id);
CREATE INDEX idx_throughput_metrics_unit_date ON throughput_metrics(unit_id, metric_date);

-- Create Views
CREATE OR REPLACE VIEW vw_current_census AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(pl.location_id) as occupied_beds,
    nu.total_beds - COUNT(pl.location_id) as available_beds
FROM nursing_unit nu
LEFT JOIN patient_location pl ON 
    nu.unit_id = pl.unit_id AND 
    pl.is_current = true
GROUP BY nu.unit_id, nu.unit_name, nu.total_beds;

CREATE OR REPLACE VIEW vw_pending_discharges AS
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    pv.visit_id,
    pv.expected_discharge_date,
    pl.unit_id,
    pl.room,
    pl.bed
FROM patient p
JOIN patient_visit pv ON p.patient_id = pv.patient_id
JOIN patient_location pl ON 
    pv.visit_id = pl.visit_id AND 
    pl.is_current = true
WHERE 
    pv.visit_status = 'ACTIVE' AND
    pv.expected_discharge_date = CURRENT_DATE;

CREATE OR REPLACE VIEW vw_unit_throughput AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    DATE(ps.status_datetime) as metric_date,
    SUM(CASE WHEN ps.status_type = 'ADMISSION' THEN 1 ELSE 0 END) as admissions,
    SUM(CASE WHEN ps.status_type = 'DISCHARGE' THEN 1 ELSE 0 END) as discharges,
    SUM(CASE WHEN ps.status_type = 'TRANSFER' THEN 1 ELSE 0 END) as transfers
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id
JOIN patient_status ps ON pl.visit_id = ps.visit_id
GROUP BY nu.unit_id, nu.unit_name, DATE(ps.status_datetime);

-- Additional Operational Views

-- View for nurse-to-patient ratio by unit
CREATE OR REPLACE VIEW vw_nurse_patient_ratio AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT pl.visit_id) as patient_count,
    COUNT(DISTINCT CASE WHEN ct.role = 'RN' AND ct.end_datetime IS NULL THEN ct.provider_id END) as nurse_count,
    ROUND(COUNT(DISTINCT pl.visit_id)::NUMERIC / 
          NULLIF(COUNT(DISTINCT CASE WHEN ct.role = 'RN' AND ct.end_datetime IS NULL THEN ct.provider_id END), 0), 2) as ratio
FROM nursing_unit nu
LEFT JOIN patient_location pl ON 
    nu.unit_id = pl.unit_id AND 
    pl.is_current = true
LEFT JOIN clinical_team ct ON 
    pl.visit_id = ct.visit_id
GROUP BY nu.unit_id, nu.unit_name;

-- Additional Quality and Financial Trending Views

-- Quality Metrics Trending
CREATE OR REPLACE VIEW vw_quality_metrics_trends AS
WITH monthly_metrics AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        DATE_TRUNC('month', ps.status_datetime) as month,
        -- Falls per 1000 patient days
        (COUNT(DISTINCT CASE 
            WHEN ce.event_type = 'FALL_INCIDENT' 
            THEN ce.event_id 
        END) * 1000.0) / 
        NULLIF(SUM(los.current_los_days), 0) as falls_per_1000_days,
        -- Hospital Acquired Infections
        COUNT(DISTINCT CASE 
            WHEN ce.event_type = 'INFECTION' AND ce.status = 'HOSPITAL_ACQUIRED'
            THEN ce.event_id 
        END) as hai_count,
        -- Medication Errors
        COUNT(DISTINCT CASE 
            WHEN ce.event_type = 'MEDICATION_ERROR'
            THEN ce.event_id 
        END) as med_errors,
        -- Pressure Injuries
        COUNT(DISTINCT CASE 
            WHEN ce.event_type = 'PRESSURE_INJURY' AND ce.status = 'HOSPITAL_ACQUIRED'
            THEN ce.event_id 
        END) as pressure_injuries,
        -- Rapid Response Team Calls
        COUNT(DISTINCT CASE 
            WHEN ce.event_type = 'RAPID_RESPONSE'
            THEN ce.event_id 
        END) as rrt_calls
    FROM nursing_unit nu
    JOIN patient_location pl ON nu.unit_id = pl.unit_id
    JOIN patient_status ps ON pl.visit_id = ps.visit_id
    JOIN length_of_stay los ON pl.visit_id = los.visit_id
    LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
    WHERE ps.status_datetime >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('month', ps.status_datetime)
)
SELECT
    unit_id,
    unit_name,
    month,
    falls_per_1000_days,
    hai_count,
    med_errors,
    pressure_injuries,
    rrt_calls,
    AVG(falls_per_1000_days) OVER (
        PARTITION BY unit_id 
        ORDER BY month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as falls_3month_avg,
    AVG(hai_count) OVER (
        PARTITION BY unit_id 
        ORDER BY month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as hai_3month_avg,
    AVG(med_errors) OVER (
        PARTITION BY unit_id 
        ORDER BY month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as med_errors_3month_avg
FROM monthly_metrics;

-- Financial Metrics Trending
CREATE OR REPLACE VIEW vw_financial_metrics_trends AS
WITH monthly_financials AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        DATE_TRUNC('month', ps.status_datetime) as month,
        -- Average Length of Stay
        AVG(los.current_los_days) as avg_los,
        -- Case Mix Index (sample calculation)
        AVG(CASE 
            WHEN od.detail_type = 'DRG_WEIGHT' 
            THEN od.detail_value::numeric 
        END) as case_mix_index,
        -- Observation Hours
        SUM(CASE 
            WHEN pv.patient_class = 'OBSERVATION'
            THEN EXTRACT(EPOCH FROM (
                COALESCE(pv.actual_discharge_date, CURRENT_TIMESTAMP) - 
                pv.admission_date
            )) / 3600 
        END) as observation_hours,
        -- Direct Variable Costs (sample calculation)
        COUNT(DISTINCT o.order_id) * 100 as estimated_variable_costs,
        -- Revenue (sample calculation)
        COUNT(DISTINCT pv.visit_id) * 1000 as estimated_revenue
    FROM nursing_unit nu
    JOIN patient_location pl ON nu.unit_id = pl.unit_id
    JOIN patient_status ps ON pl.visit_id = ps.visit_id
    JOIN patient_visit pv ON pl.visit_id = pv.visit_id
    JOIN length_of_stay los ON pl.visit_id = los.visit_id
    LEFT JOIN "order" o ON pl.visit_id = o.visit_id
    LEFT JOIN order_detail od ON o.order_id = od.order_id
    WHERE ps.status_datetime >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('month', ps.status_datetime)
)
SELECT
    unit_id,
    unit_name,
    month,
    avg_los,
    case_mix_index,
    observation_hours,
    estimated_variable_costs,
    estimated_revenue,
    estimated_revenue - estimated_variable_costs as estimated_contribution_margin,
    -- Trailing metrics
    AVG(avg_los) OVER (
        PARTITION BY unit_id 
        ORDER BY month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as los_3month_avg,
    AVG(case_mix_index) OVER (
        PARTITION BY unit_id 
        ORDER BY month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as cmi_3month_avg,
    -- Year over Year comparison
    LAG(estimated_revenue, 12) OVER (
        PARTITION BY unit_id 
        ORDER BY month
    ) as revenue_previous_year,
    ((estimated_revenue - LAG(estimated_revenue, 12) OVER (
        PARTITION BY unit_id 
        ORDER BY month
    )) / NULLIF(LAG(estimated_revenue, 12) OVER (
        PARTITION BY unit_id 
        ORDER BY month
    ), 0) * 100) as revenue_yoy_change
FROM monthly_financials;

-- Enhanced Existing Views with KPIs

-- Enhanced Charge Nurse Dashboard
CREATE OR REPLACE VIEW vw_enhanced_charge_nurse_dashboard AS
WITH staffing_metrics AS (
    SELECT 
        nu.unit_id,
        COUNT(DISTINCT CASE WHEN ct.role = 'RN' THEN ct.provider_id END) as rn_count,
        COUNT(DISTINCT CASE WHEN ct.role = 'CNA' THEN ct.provider_id END) as cna_count,
        COUNT(DISTINCT pl.visit_id) as patient_count,
        SUM(CASE 
            WHEN ce.event_type = 'ACUITY_ASSESSMENT' 
            THEN ce.severity::integer 
        END) as total_acuity_score
    FROM nursing_unit nu
    LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
    LEFT JOIN clinical_team ct ON pl.visit_id = ct.visit_id
    LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
    WHERE ct.end_datetime IS NULL
    GROUP BY nu.unit_id
)
SELECT 
    nu.unit_id,
    nu.unit_name,
    sm.rn_count,
    sm.cna_count,
    sm.patient_count,
    -- Calculated KPIs
    ROUND(sm.patient_count::numeric / NULLIF(sm.rn_count, 0), 2) as nurse_patient_ratio,
    ROUND(sm.total_acuity_score::numeric / NULLIF(sm.patient_count, 0), 2) as avg_acuity_score,
    COUNT(DISTINCT CASE 
        WHEN ce.severity IN ('HIGH', 'CRITICAL') 
        THEN pl.visit_id 
    END) as high_acuity_count,
    COUNT(DISTINCT CASE 
        WHEN o.priority = 'STAT' AND o.order_status = 'PENDING' 
        THEN o.order_id 
    END) as pending_stat_orders,
    COUNT(DISTINCT CASE 
        WHEN pv.expected_discharge_date = CURRENT_DATE 
        THEN pv.visit_id 
    END) as todays_discharges,
    -- Additional KPIs
    COUNT(DISTINCT CASE 
        WHEN ce.event_type = 'FALL_RISK' AND ce.severity = 'HIGH'
        THEN pl.visit_id 
    END) as high_fall_risk_count,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'ISOLATION' 
        THEN pl.visit_id 
    END) as isolation_patients,
    COUNT(DISTINCT CASE 
        WHEN ce.event_type = 'RAPID_RESPONSE' 
        AND ce.event_datetime >= CURRENT_TIMESTAMP - INTERVAL '12 hours'
        THEN ce.event_id 
    END) as rrt_calls_12hr,
    -- Workload Index (custom metric combining multiple factors)
    ROUND((
        (sm.patient_count::numeric / NULLIF(sm.rn_count, 0)) * 
        (sm.total_acuity_score::numeric / NULLIF(sm.patient_count, 0)) +
        (COUNT(DISTINCT CASE 
            WHEN o.priority = 'STAT' 
            THEN o.order_id 
        END)::numeric / 10)
    ), 2) as workload_index
FROM nursing_unit nu
JOIN staffing_metrics sm ON nu.unit_id = sm.unit_id
LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id 
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN patient_visit pv ON pl.visit_id = pv.visit_id
GROUP BY nu.unit_id, nu.unit_name, sm.rn_count, sm.cna_count, sm.patient_count, sm.total_acuity_score;

-- Enhanced Bed Manager Dashboard
CREATE OR REPLACE VIEW vw_enhanced_bed_manager_dashboard AS
WITH bed_metrics AS (
    SELECT 
        nu.unit_id,
        COUNT(DISTINCT CASE WHEN pl.status = 'occupied' THEN pl.location_id END) as occupied_beds,
        COUNT(DISTINCT CASE WHEN pl.status = 'available' THEN pl.location_id END) as available_beds,
        COUNT(DISTINCT CASE WHEN pl.status = 'blocked' THEN pl.location_id END) as blocked_beds,
        nu.total_beds
    FROM nursing_unit nu
    LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
    GROUP BY nu.unit_id, nu.total_beds
)
SELECT 
    nu.unit_id,
    nu.unit_name,
    bm.total_beds,
    bm.occupied_beds,
    bm.available_beds,
    bm.blocked_beds,
    -- Calculated KPIs
    ROUND((bm.occupied_beds::numeric / NULLIF(bm.total_beds, 0)) * 100, 1) as occupancy_rate,
    ROUND((bm.blocked_beds::numeric / NULLIF(bm.total_beds, 0)) * 100, 1) as blocked_rate,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'BED_PLACEMENT' AND o.order_status = 'PENDING'
        THEN o.order_id 
    END) as pending_placements,
    COUNT(DISTINCT CASE 
        WHEN pv.expected_discharge_date <= CURRENT_DATE + INTERVAL '4 hours'
        THEN pv.visit_id 
    END) as upcoming_discharges,
    -- Additional KPIs
    AVG(EXTRACT(EPOCH FROM (
        o.start_datetime - o.order_datetime
    )) / 3600) FILTER (
        WHERE o.order_type = 'BED_PLACEMENT' 
        AND o.order_status = 'COMPLETED'
    ) as avg_placement_time_hours,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'BED_PLACEMENT' 
        AND o.priority = 'STAT'
        AND o.order_status = 'PENDING'
        THEN o.order_id 
    END) as pending_stat_placements,
    -- Efficiency Metrics
    ROUND((
        COUNT(DISTINCT CASE 
            WHEN pv.actual_discharge_date::date = CURRENT_DATE 
            THEN pv.visit_id 
        END)::numeric / NULLIF(bm.total_beds, 0)
    ) * 100, 1) as daily_turnover_rate,
    AVG(EXTRACT(EPOCH FROM (
        pl.start_datetime - LAG(pl.end_datetime) OVER (
            PARTITION BY pl.room, pl.bed 
            ORDER BY pl.start_datetime
        )
    )) / 60) as avg_bed_turnover_minutes
FROM nursing_unit nu
JOIN bed_metrics bm ON nu.unit_id = bm.unit_id
LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN patient_visit pv ON pl.visit_id = pv.visit_id
GROUP BY nu.unit_id, nu.unit_name, bm.total_beds, bm.occupied_beds, bm.available_beds, bm.blocked_beds;

-- Advanced Financial Metrics
CREATE OR REPLACE VIEW vw_advanced_financial_metrics AS
WITH daily_metrics AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        DATE_TRUNC('day', ps.status_datetime) as metric_date,
        COUNT(DISTINCT pl.visit_id) as daily_census,
        COUNT(DISTINCT CASE 
            WHEN ps.status_type = 'DISCHARGE' 
            THEN ps.visit_id 
        END) as daily_discharges,
        -- Sample revenue calculations (replace with actual revenue data)
        SUM(CASE 
            WHEN od.detail_type = 'DRG_PAYMENT' 
            THEN od.detail_value::numeric 
        END) as drg_revenue,
        SUM(CASE 
            WHEN od.detail_type = 'SUPPLY_COST' 
            THEN od.detail_value::numeric 
        END) as supply_costs,
        SUM(CASE 
            WHEN od.detail_type = 'PHARMACY_COST' 
            THEN od.detail_value::numeric 
        END) as pharmacy_costs,
        SUM(CASE 
            WHEN od.detail_type = 'PROCEDURE_COST' 
            THEN od.detail_value::numeric 
        END) as procedure_costs,
        -- Staffing costs (sample calculation)
        COUNT(DISTINCT ct.provider_id) * 500 as staffing_costs
    FROM nursing_unit nu
    JOIN patient_location pl ON nu.unit_id = pl.unit_id
    JOIN patient_status ps ON pl.visit_id = ps.visit_id
    LEFT JOIN "order" o ON pl.visit_id = o.visit_id
    LEFT JOIN order_detail od ON o.order_id = od.order_id
    LEFT JOIN clinical_team ct ON pl.visit_id = ct.visit_id
    WHERE ps.status_datetime >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('day', ps.status_datetime)
)
SELECT
    unit_id,
    unit_name,
    metric_date,
    -- Basic metrics
    daily_census,
    daily_discharges,
    drg_revenue,
    supply_costs + pharmacy_costs + procedure_costs + staffing_costs as total_direct_costs,
    -- Per patient day metrics
    ROUND(drg_revenue / NULLIF(daily_census, 0), 2) as revenue_per_patient_day,
    ROUND((supply_costs + pharmacy_costs) / NULLIF(daily_census, 0), 2) as variable_cost_per_patient_day,
    ROUND(staffing_costs / NULLIF(daily_census, 0), 2) as staffing_cost_per_patient_day,
    -- Per discharge metrics
    ROUND(drg_revenue / NULLIF(daily_discharges, 0), 2) as revenue_per_discharge,
    ROUND((supply_costs + pharmacy_costs + procedure_costs) / NULLIF(daily_discharges, 0), 2) as cost_per_discharge,
    -- Contribution margins
    ROUND((drg_revenue - (supply_costs + pharmacy_costs + procedure_costs)) / NULLIF(daily_census, 0), 2) as contribution_margin_per_day,
    -- Efficiency metrics
    ROUND((drg_revenue - (supply_costs + pharmacy_costs + procedure_costs + staffing_costs)) / NULLIF(drg_revenue, 0) * 100, 1) as operating_margin_percentage,
    -- Resource utilization
    ROUND(pharmacy_costs / NULLIF(drg_revenue, 0) * 100, 1) as pharmacy_cost_percentage,
    ROUND(supply_costs / NULLIF(drg_revenue, 0) * 100, 1) as supply_cost_percentage,
    -- Rolling averages
    AVG(drg_revenue) OVER (
        PARTITION BY unit_id 
        ORDER BY metric_date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as rolling_30day_avg_revenue,
    AVG(supply_costs + pharmacy_costs + procedure_costs) OVER (
        PARTITION BY unit_id 
        ORDER BY metric_date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as rolling_30day_avg_costs
FROM daily_metrics;

-- Advanced Quality Indicators
CREATE OR REPLACE VIEW vw_advanced_quality_indicators AS
WITH patient_metrics AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        pv.visit_id,
        -- Readmission risk factors
        COUNT(DISTINCT CASE 
            WHEN ce.event_type = 'COMORBIDITY' 
            THEN ce.event_id 
        END) as comorbidity_count,
        MAX(CASE 
            WHEN ce.event_type = 'ACUITY_ASSESSMENT' 
            THEN ce.severity::integer 
        END) as max_acuity,
        COUNT(DISTINCT CASE 
            WHEN o.order_type = 'MEDICATION' 
            THEN o.order_id 
        END) as medication_count,
        -- Previous admissions in last 30 days
        COUNT(DISTINCT CASE 
            WHEN pv2.admission_date >= pv.admission_date - INTERVAL '30 days'
            AND pv2.visit_id != pv.visit_id
            THEN pv2.visit_id 
        END) as recent_admissions,
        -- Quality indicators
        BOOL_OR(ce.event_type = 'FALL_INCIDENT') as had_fall,
        BOOL_OR(ce.event_type = 'PRESSURE_INJURY') as had_pressure_injury,
        BOOL_OR(ce.event_type = 'MEDICATION_ERROR') as had_med_error,
        BOOL_OR(ce.event_type = 'HOSPITAL_ACQUIRED_INFECTION') as had_hai
    FROM nursing_unit nu
    JOIN patient_location pl ON nu.unit_id = pl.unit_id
    JOIN patient_visit pv ON pl.visit_id = pv.visit_id
    LEFT JOIN patient_visit pv2 ON pv.patient_id = pv2.patient_id
    LEFT JOIN clinical_event ce ON pv.visit_id = ce.visit_id
    LEFT JOIN "order" o ON pv.visit_id = o.visit_id
    WHERE pv.admission_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY nu.unit_id, nu.unit_name, pv.visit_id
)
SELECT
    unit_id,
    unit_name,
    -- Risk Scores (sample calculations)
    AVG(
        CASE
            WHEN comorbidity_count > 3 THEN 3
            ELSE comorbidity_count
        END * 2 +
        CASE
            WHEN max_acuity >= 4 THEN 3
            WHEN max_acuity >= 3 THEN 2
            ELSE 1
        END +
        CASE
            WHEN medication_count > 10 THEN 3
            WHEN medication_count > 5 THEN 2
            ELSE 1
        END +
        CASE
            WHEN recent_admissions > 0 THEN 3
            ELSE 0
        END
    ) as avg_readmission_risk_score,
    -- Mortality Risk Score (sample calculation)
    AVG(
        CASE
            WHEN comorbidity_count > 3 THEN 4
            ELSE comorbidity_count
        END +
        CASE
            WHEN max_acuity >= 4 THEN 4
            WHEN max_acuity >= 3 THEN 2
            ELSE 0
        END +
        CASE
            WHEN medication_count > 15 THEN 2
            ELSE 0
        END
    ) as avg_mortality_risk_score,
    -- Quality Event Rates
    ROUND(COUNT(CASE WHEN had_fall THEN 1 END)::numeric / 
          NULLIF(COUNT(*), 0) * 1000, 2) as falls_per_1000_visits,
    ROUND(COUNT(CASE WHEN had_pressure_injury THEN 1 END)::numeric / 
          NULLIF(COUNT(*), 0) * 1000, 2) as pressure_injuries_per_1000_visits,
    ROUND(COUNT(CASE WHEN had_med_error THEN 1 END)::numeric / 
          NULLIF(COUNT(*), 0) * 1000, 2) as med_errors_per_1000_visits,
    ROUND(COUNT(CASE WHEN had_hai THEN 1 END)::numeric / 
          NULLIF(COUNT(*), 0) * 1000, 2) as hai_per_1000_visits,
    -- Risk Stratification
    COUNT(CASE 
        WHEN comorbidity_count >= 3 AND max_acuity >= 3 
        THEN 1 
    END) as high_risk_patient_count,
    -- Composite Quality Score (lower is better)
    ROUND((
        COUNT(CASE WHEN had_fall THEN 1 END)::numeric / NULLIF(COUNT(*), 0) * 10 +
        COUNT(CASE WHEN had_pressure_injury THEN 1 END)::numeric / NULLIF(COUNT(*), 0) * 15 +
        COUNT(CASE WHEN had_med_error THEN 1 END)::numeric / NULLIF(COUNT(*), 0) * 20 +
        COUNT(CASE WHEN had_hai THEN 1 END)::numeric / NULLIF(COUNT(*), 0) * 25
    ) * 100, 2) as composite_quality_score
FROM patient_metrics
GROUP BY unit_id, unit_name;

-- Granular Financial Breakdowns
CREATE OR REPLACE VIEW vw_detailed_financial_metrics AS
WITH financial_details AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        DATE_TRUNC('day', ps.status_datetime) as metric_date,
        -- Revenue Components
        SUM(CASE WHEN od.detail_type = 'DRG_BASE' THEN od.detail_value::numeric END) as drg_base,
        SUM(CASE WHEN od.detail_type = 'DRG_OUTLIER' THEN od.detail_value::numeric END) as drg_outlier,
        SUM(CASE WHEN od.detail_type = 'PROCEDURE_REVENUE' THEN od.detail_value::numeric END) as procedure_revenue,
        SUM(CASE WHEN od.detail_type = 'PHARMACY_REVENUE' THEN od.detail_value::numeric END) as pharmacy_revenue,
        SUM(CASE WHEN od.detail_type = 'SUPPLY_REVENUE' THEN od.detail_value::numeric END) as supply_revenue,
        -- Direct Costs
        SUM(CASE WHEN od.detail_type = 'NURSING_LABOR' THEN od.detail_value::numeric END) as nursing_labor,
        SUM(CASE WHEN od.detail_type = 'AIDE_LABOR' THEN od.detail_value::numeric END) as aide_labor,
        SUM(CASE WHEN od.detail_type = 'PHARMACY_COST' THEN od.detail_value::numeric END) as pharmacy_cost,
        SUM(CASE WHEN od.detail_type = 'SUPPLY_COST' THEN od.detail_value::numeric END) as supply_cost,
        SUM(CASE WHEN od.detail_type = 'PROCEDURE_COST' THEN od.detail_value::numeric END) as procedure_cost,
        -- Indirect Costs
        SUM(CASE WHEN od.detail_type = 'OVERHEAD_COST' THEN od.detail_value::numeric END) as overhead_cost,
        SUM(CASE WHEN od.detail_type = 'ADMIN_COST' THEN od.detail_value::numeric END) as admin_cost,
        COUNT(DISTINCT pv.visit_id) as patient_count
    FROM nursing_unit nu
    JOIN patient_location pl ON nu.unit_id = pl.unit_id
    JOIN patient_status ps ON pl.visit_id = ps.visit_id
    JOIN patient_visit pv ON pl.visit_id = pv.visit_id
    LEFT JOIN "order" o ON pl.visit_id = o.visit_id
    LEFT JOIN order_detail od ON o.order_id = od.order_id
    WHERE ps.status_datetime >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('day', ps.status_datetime)
)
SELECT
    unit_id,
    unit_name,
    metric_date,
    -- Revenue Analysis
    drg_base + drg_outlier + procedure_revenue + pharmacy_revenue + supply_revenue as total_revenue,
    ROUND((drg_base + drg_outlier) / NULLIF(total_revenue, 0) * 100, 1) as drg_revenue_percentage,
    ROUND(procedure_revenue / NULLIF(total_revenue, 0) * 100, 1) as procedure_revenue_percentage,
    ROUND(pharmacy_revenue / NULLIF(total_revenue, 0) * 100, 1) as pharmacy_revenue_percentage,
    -- Direct Cost Analysis
    nursing_labor + aide_labor + pharmacy_cost + supply_cost + procedure_cost as total_direct_cost,
    ROUND(nursing_labor / NULLIF(total_direct_cost, 0) * 100, 1) as labor_cost_percentage,
    ROUND(pharmacy_cost / NULLIF(total_direct_cost, 0) * 100, 1) as pharmacy_cost_percentage,
    -- Per Patient Metrics
    ROUND((total_revenue - total_direct_cost) / NULLIF(patient_count, 0), 2) as contribution_margin_per_patient,
    ROUND(total_direct_cost / NULLIF(patient_count, 0), 2) as direct_cost_per_patient,
    -- Profitability Analysis
    ROUND((total_revenue - (total_direct_cost + overhead_cost + admin_cost)) / NULLIF(total_revenue, 0) * 100, 1) as operating_margin_percentage
FROM financial_details;

-- Enhanced Risk Factors and Quality Indicators
CREATE OR REPLACE VIEW vw_enhanced_quality_risk AS
WITH patient_risk_factors AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        pv.visit_id,
        -- Clinical Risk Factors
        COUNT(DISTINCT CASE WHEN ce.event_type = 'COMORBIDITY' THEN ce.event_id END) as comorbidity_count,
        MAX(CASE WHEN ce.event_type = 'ACUITY_ASSESSMENT' THEN ce.severity::integer END) as acuity_score,
        COUNT(DISTINCT CASE WHEN o.order_type = 'MEDICATION' THEN o.order_id END) as medication_count,
        -- Social Determinants
        BOOL_OR(ce.event_type = 'SOCIAL_SUPPORT_ASSESSMENT' AND ce.status = 'LOW') as low_social_support,
        BOOL_OR(ce.event_type = 'TRANSPORTATION_ASSESSMENT' AND ce.status = 'BARRIER') as transportation_barrier,
        BOOL_OR(ce.event_type = 'HOUSING_ASSESSMENT' AND ce.status = 'UNSTABLE') as housing_instability,
        -- Clinical Outcomes
        BOOL_OR(ce.event_type = 'FALL_INCIDENT') as had_fall,
        BOOL_OR(ce.event_type = 'PRESSURE_INJURY') as had_pressure_injury,
        BOOL_OR(ce.event_type = 'MEDICATION_ERROR') as had_med_error,
        BOOL_OR(ce.event_type = 'HOSPITAL_ACQUIRED_INFECTION') as had_hai,
        -- Additional Risk Factors
        BOOL_OR(ce.event_type = 'COGNITIVE_ASSESSMENT' AND ce.status = 'IMPAIRED') as cognitive_impairment,
        BOOL_OR(ce.event_type = 'MOBILITY_ASSESSMENT' AND ce.status = 'IMPAIRED') as mobility_impairment,
        BOOL_OR(ce.event_type = 'NUTRITION_ASSESSMENT' AND ce.status = 'AT_RISK') as nutrition_risk
    FROM nursing_unit nu
    JOIN patient_location pl ON nu.unit_id = pl.unit_id
    JOIN patient_visit pv ON pl.visit_id = pv.visit_id
    LEFT JOIN clinical_event ce ON pv.visit_id = ce.visit_id
    LEFT JOIN "order" o ON pv.visit_id = o.visit_id
    WHERE pv.admission_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY nu.unit_id, nu.unit_name, pv.visit_id
)
SELECT
    unit_id,
    unit_name,
    -- Enhanced Risk Scores
    AVG(
        comorbidity_count * 2 +
        acuity_score * 1.5 +
        CASE WHEN medication_count > 10 THEN 3 ELSE 1 END +
        CASE WHEN low_social_support THEN 2 ELSE 0 END +
        CASE WHEN transportation_barrier THEN 1 ELSE 0 END +
        CASE WHEN housing_instability THEN 2 ELSE 0 END +
        CASE WHEN cognitive_impairment THEN 2 ELSE 0 END +
        CASE WHEN mobility_impairment THEN 2 ELSE 0 END +
        CASE WHEN nutrition_risk THEN 1 ELSE 0 END
    ) as comprehensive_risk_score,
    -- Social Risk Score
    AVG(
        CASE WHEN low_social_support THEN 3 ELSE 0 END +
        CASE WHEN transportation_barrier THEN 2 ELSE 0 END +
        CASE WHEN housing_instability THEN 3 ELSE 0 END
    ) as social_risk_score,
    -- Clinical Risk Score
    AVG(
        comorbidity_count * 2 +
        acuity_score * 1.5 +
        CASE WHEN cognitive_impairment THEN 2 ELSE 0 END +
        CASE WHEN mobility_impairment THEN 2 ELSE 0 END +
        CASE WHEN nutrition_risk THEN 1 ELSE 0 END
    ) as clinical_risk_score
FROM patient_risk_factors
GROUP BY unit_id, unit_name;

-- Integrated Performance Dashboard
CREATE OR REPLACE VIEW vw_integrated_performance_dashboard AS
WITH metrics AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        -- Census and Staffing
        COUNT(DISTINCT pl.visit_id) as current_census,
        COUNT(DISTINCT CASE WHEN ct.role = 'RN' THEN ct.provider_id END) as rn_count,
        -- Financial Metrics from detailed_financial_metrics
        df.total_revenue,
        df.total_direct_cost,
        df.operating_margin_percentage,
        -- Quality Metrics from enhanced_quality_risk
        eq.comprehensive_risk_score,
        eq.social_risk_score,
        eq.clinical_risk_score
    FROM nursing_unit nu
    LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
    LEFT JOIN clinical_team ct ON pl.visit_id = ct.visit_id
    LEFT JOIN vw_detailed_financial_metrics df ON nu.unit_id = df.unit_id
    LEFT JOIN vw_enhanced_quality_risk eq ON nu.unit_id = eq.unit_id
    GROUP BY 
        nu.unit_id, 
        nu.unit_name,
        df.total_revenue,
        df.total_direct_cost,
        df.operating_margin_percentage,
        eq.comprehensive_risk_score,
        eq.social_risk_score,
        eq.clinical_risk_score
)
SELECT
    unit_id,
    unit_name,
    -- Operational Metrics
    current_census,
    rn_count,
    ROUND(current_census::numeric / NULLIF(rn_count, 0), 2) as nurse_patient_ratio,
    -- Financial Performance
    total_revenue,
    total_direct_cost,
    operating_margin_percentage,
    -- Risk and Quality Metrics
    comprehensive_risk_score,
    social_risk_score,
    clinical_risk_score,
    -- Composite Performance Score (example calculation)
    ROUND(
        (operating_margin_percentage * 0.4) +
        ((1 - (comprehensive_risk_score / 10)) * 30) +
        ((1 - (current_census::numeric / NULLIF(rn_count, 0) / 6)) * 30)
    , 2) as composite_performance_score
FROM metrics;


-- Additional Trending Analysis Views

-- Boarding Time Trends
CREATE OR REPLACE VIEW vw_boarding_time_trends AS
SELECT
    DATE_TRUNC('day', o.order_datetime) as date,
    COUNT(DISTINCT o.visit_id) as total_holds,
    AVG(EXTRACT(EPOCH FROM (
        COALESCE(o.start_datetime, CURRENT_TIMESTAMP) - o.order_datetime
    )) / 3600) as avg_boarding_hours,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY EXTRACT(EPOCH FROM (
            COALESCE(o.start_datetime, CURRENT_TIMESTAMP) - o.order_datetime
        )) / 3600
    ) as median_boarding_hours,
    COUNT(DISTINCT CASE 
        WHEN EXTRACT(EPOCH FROM (
            COALESCE(o.start_datetime, CURRENT_TIMESTAMP) - o.order_datetime
        )) / 3600 > 24 THEN o.visit_id 
    END) as extended_holds
FROM "order" o
WHERE o.order_type = 'BED_PLACEMENT'
AND o.order_datetime >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE_TRUNC('day', o.order_datetime);

-- Seasonal Admission Pattern Analysis
CREATE OR REPLACE VIEW vw_seasonal_patterns AS
SELECT
    nu.unit_id,
    nu.unit_name,
    EXTRACT(MONTH FROM ps.status_datetime) as month,
    EXTRACT(DOW FROM ps.status_datetime) as day_of_week,
    COUNT(*) as admission_count,
    AVG(COUNT(*)) OVER (
        PARTITION BY nu.unit_id, 
        EXTRACT(MONTH FROM ps.status_datetime),
        EXTRACT(DOW FROM ps.status_datetime)
    ) as avg_daily_admissions,
    STDDEV(COUNT(*)) OVER (
        PARTITION BY nu.unit_id,
        EXTRACT(MONTH FROM ps.status_datetime),
        EXTRACT(DOW FROM ps.status_datetime)
    ) as stddev_admissions
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id
JOIN patient_status ps ON pl.visit_id = ps.visit_id
WHERE ps.status_type = 'ADMISSION'
AND ps.status_datetime >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY 
    nu.unit_id,
    nu.unit_name,
    EXTRACT(MONTH FROM ps.status_datetime),
    EXTRACT(DOW FROM ps.status_datetime);

-- Staff Satisfaction and Workload Correlation
CREATE OR REPLACE VIEW vw_workload_satisfaction_trends AS
WITH shift_metrics AS (
    SELECT
        nu.unit_id,
        nu.unit_name,
        DATE_TRUNC('shift', ce.event_datetime) as shift_start,
        COUNT(DISTINCT pl.visit_id) / NULLIF(COUNT(DISTINCT ct.provider_id), 0) as patient_staff_ratio,
        COUNT(DISTINCT o.order_id) as orders_per_shift,
        COUNT(DISTINCT CASE 
            WHEN ce.severity IN ('HIGH', 'CRITICAL') 
            THEN ce.event_id 
        END) as critical_events
    FROM nursing_unit nu
    JOIN patient_location pl ON nu.unit_id = pl.unit_id
    JOIN clinical_team ct ON pl.visit_id = ct.visit_id
    LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
    LEFT JOIN "order" o ON pl.visit_id = o.visit_id
    WHERE ce.event_datetime >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('shift', ce.event_datetime)
)
SELECT
    unit_id,
    unit_name,
    DATE_TRUNC('week', shift_start) as week,
    AVG(patient_staff_ratio) as avg_patient_ratio,
    AVG(orders_per_shift) as avg_orders,
    AVG(critical_events) as avg_critical_events,
    CORR(patient_staff_ratio, critical_events) as workload_event_correlation
FROM shift_metrics
GROUP BY unit_id, unit_name, DATE_TRUNC('week', shift_start);

-- Additional Ancillary Service Views

-- Dietary Services Dashboard
CREATE OR REPLACE VIEW vw_dietary_services_dashboard AS
SELECT
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT pl.visit_id) as total_patients,
    COUNT(DISTINCT CASE 
        WHEN od.detail_type = 'DIET_RESTRICTION' 
        THEN pl.visit_id 
    END) as special_diet_count,
    STRING_AGG(DISTINCT od.detail_value, ', ') as dietary_restrictions,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'DIET' AND o.order_status = 'PENDING' 
        THEN o.order_id 
    END) as pending_diet_orders,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'NUTRITION_CONSULT' 
        THEN o.order_id 
    END) as nutrition_consults
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN order_detail od ON o.order_id = od.order_id
GROUP BY nu.unit_id, nu.unit_name;

-- Respiratory Therapy Dashboard
CREATE OR REPLACE VIEW vw_respiratory_therapy_dashboard AS
SELECT
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'RESPIRATORY_THERAPY' 
        THEN pl.visit_id 
    END) as rt_patients,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'RESPIRATORY_THERAPY' 
        AND o.order_status = 'PENDING' 
        THEN o.order_id 
    END) as pending_treatments,
    COUNT(DISTINCT CASE 
        WHEN ce.event_type = 'RESPIRATORY_ASSESSMENT' 
        AND ce.severity IN ('HIGH', 'CRITICAL')
        THEN ce.event_id 
    END) as critical_respiratory_events,
    STRING_AGG(DISTINCT od.detail_value, ', ') FILTER (
        WHERE od.detail_type = 'VENTILATOR_TYPE'
    ) as ventilator_types_in_use
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN order_detail od ON o.order_id = od.order_id
LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
GROUP BY nu.unit_id, nu.unit_name;

-- Physical Therapy Dashboard
CREATE OR REPLACE VIEW vw_physical_therapy_dashboard AS
SELECT
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'PT_CONSULT' 
        THEN pl.visit_id 
    END) as active_pt_patients,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'PT_CONSULT' 
        AND o.order_status = 'PENDING' 
        THEN o.order_id 
    END) as pending_evaluations,
    COUNT(DISTINCT CASE 
        WHEN ce.event_type = 'PT_ASSESSMENT' 
        AND ce.event_datetime::date = CURRENT_DATE
        THEN ce.event_id 
    END) as completed_today,
    AVG(CASE 
        WHEN o.order_type = 'PT_CONSULT' 
        THEN EXTRACT(EPOCH FROM (o.start_datetime - o.order_datetime)) / 3600 
    END) as avg_consult_response_hours
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
GROUP BY nu.unit_id, nu.unit_name;

-- Radiology Services Dashboard
CREATE OR REPLACE VIEW vw_radiology_dashboard AS
WITH rad_orders AS (
    SELECT
        pl.unit_id,
        o.order_id,
        o.visit_id,
        o.order_status,
        o.priority,
        od.detail_value as study_type,
        o.order_datetime,
        o.start_datetime,
        o.end_datetime
    FROM "order" o
    JOIN patient_location pl ON o.visit_id = pl.visit_id
    JOIN order_detail od ON o.order_id = od.order_id
    WHERE o.order_type = 'RADIOLOGY'
    AND pl.is_current = true
)
SELECT
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE 
        WHEN ro.order_status = 'PENDING' 
        THEN ro.order_id 
    END) as pending_studies,
    COUNT(DISTINCT CASE 
        WHEN ro.priority = 'STAT' AND ro.order_status = 'PENDING' 
        THEN ro.order_id 
    END) as pending_stat_studies,
    AVG(CASE 
        WHEN ro.order_status = 'COMPLETED'
        THEN EXTRACT(EPOCH FROM (ro.end_datetime - ro.start_datetime)) / 60 
    END) as avg_completion_time_mins,
    STRING_AGG(DISTINCT CASE 
        WHEN ro.order_status = 'PENDING'
        THEN ro.study_type 
    END, ', ') as pending_study_types
FROM nursing_unit nu
LEFT JOIN rad_orders ro ON nu.unit_id = ro.unit_id
GROUP BY nu.unit_id, nu.unit_name;

-- Additional Clinical Scenario Views

-- Fall Risk Assessment Dashboard
CREATE OR REPLACE VIEW vw_fall_risk_dashboard AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    pl.room,
    pl.bed,
    p.first_name,
    p.last_name,
    MAX(CASE WHEN ce.event_type = 'FALL_RISK_SCORE' THEN ce.severity END) as risk_level,
    STRING_AGG(DISTINCT CASE 
        WHEN od.detail_type = 'PRECAUTION' 
        THEN od.detail_value 
    END, ', ') as active_precautions,
    BOOL_OR(ce.event_type = 'FALL_INCIDENT') as had_previous_fall
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
JOIN patient_visit pv ON pl.visit_id = pv.visit_id
JOIN patient p ON pv.patient_id = p.patient_id
LEFT JOIN clinical_event ce ON pv.visit_id = ce.visit_id
LEFT JOIN "order" o ON pv.visit_id = o.visit_id
LEFT JOIN order_detail od ON o.order_id = od.order_id
GROUP BY nu.unit_id, nu.unit_name, pl.room, pl.bed, p.first_name, p.last_name;

-- Telemetry Monitoring Status
CREATE OR REPLACE VIEW vw_telemetry_monitoring AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT pl.visit_id) as total_patients,
    COUNT(DISTINCT CASE 
        WHEN od.detail_type = 'MONITORING' AND od.detail_value = 'TELEMETRY' 
        THEN pl.visit_id 
    END) as telemetry_patients,
    COUNT(DISTINCT CASE 
        WHEN ce.event_type = 'CARDIAC_EVENT' AND ce.severity IN ('HIGH', 'CRITICAL')
        AND ce.event_datetime >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
        THEN ce.event_id 
    END) as cardiac_events_24h
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN order_detail od ON o.order_id = od.order_id
LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
GROUP BY nu.unit_id, nu.unit_name;

-- Infection Control Monitoring
CREATE OR REPLACE VIEW vw_infection_control AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    od.detail_value as infection_type,
    COUNT(DISTINCT pl.visit_id) as patient_count,
    STRING_AGG(DISTINCT CASE 
        WHEN od2.detail_type = 'PRECAUTION_TYPE' 
        THEN od2.detail_value 
    END, ', ') as required_precautions
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
JOIN "order" o ON pl.visit_id = o.visit_id
JOIN order_detail od ON o.order_id = od.order_id
LEFT JOIN order_detail od2 ON o.order_id = od2.order_id
WHERE od.detail_type = 'INFECTION_TYPE'
GROUP BY nu.unit_id, nu.unit_name, od.detail_value;

-- Additional Trending Analysis Views

-- Readmission Patterns
CREATE OR REPLACE VIEW vw_readmission_trends AS
WITH readmissions AS (
    SELECT 
        pv1.visit_id,
        pv1.patient_id,
        pv1.admission_date,
        pv1.discharge_date,
        pv2.admission_date as readmit_date,
        nu.unit_id,
        nu.unit_name
    FROM patient_visit pv1
    JOIN patient_visit pv2 ON 
        pv1.patient_id = pv2.patient_id AND
        pv1.visit_id != pv2.visit_id AND
        pv2.admission_date BETWEEN pv1.discharge_date AND pv1.discharge_date + INTERVAL '30 days'
    JOIN patient_location pl ON pv1.visit_id = pl.visit_id
    JOIN nursing_unit nu ON pl.unit_id = nu.unit_id
    WHERE pv1.discharge_date >= CURRENT_DATE - INTERVAL '12 months'
)
SELECT 
    unit_id,
    unit_name,
    DATE_TRUNC('month', admission_date) as month,
    COUNT(DISTINCT visit_id) as total_discharges,
    COUNT(DISTINCT CASE WHEN readmit_date IS NOT NULL THEN visit_id END) as readmissions,
    ROUND(COUNT(DISTINCT CASE WHEN readmit_date IS NOT NULL THEN visit_id END)::NUMERIC / 
          NULLIF(COUNT(DISTINCT visit_id), 0) * 100, 2) as readmission_rate
FROM readmissions
GROUP BY unit_id, unit_name, DATE_TRUNC('month', admission_date);

-- Staff Workload Trends
CREATE OR REPLACE VIEW vw_staff_workload_trends AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    DATE_TRUNC('shift', ce.event_datetime) as shift_start,
    COUNT(DISTINCT pl.visit_id) as total_patients,
    COUNT(DISTINCT ct.provider_id) FILTER (WHERE ct.role = 'RN') as nurse_count,
    ROUND(COUNT(DISTINCT pl.visit_id)::NUMERIC / 
          NULLIF(COUNT(DISTINCT ct.provider_id) FILTER (WHERE ct.role = 'RN'), 0), 2) as nurse_patient_ratio,
    COUNT(DISTINCT o.order_id) FILTER (WHERE o.order_datetime >= shift_start) as new_orders,
    COUNT(DISTINCT ce.event_id) FILTER (WHERE ce.severity IN ('HIGH', 'CRITICAL')) as critical_events
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id
JOIN clinical_team ct ON pl.visit_id = ct.visit_id
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
WHERE ce.event_datetime >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('shift', ce.event_datetime);

-- Additional Role-Specific Views

-- Transportation Coordinator Dashboard
CREATE OR REPLACE VIEW vw_transportation_dashboard AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'TRANSPORT' AND o.order_status = 'PENDING' 
        THEN o.order_id 
    END) as pending_transports,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'TRANSPORT' AND o.order_status = 'IN_PROGRESS' 
        THEN o.order_id 
    END) as active_transports,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'TRANSPORT' AND o.priority = 'STAT' 
        THEN o.order_id 
    END) as stat_requests,
    AVG(CASE 
        WHEN o.order_type = 'TRANSPORT' AND o.order_status = 'COMPLETED'
        THEN EXTRACT(EPOCH FROM (o.end_datetime - o.start_datetime)) / 60 
    END) as avg_transport_time_mins
FROM nursing_unit nu
LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
WHERE o.order_datetime >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY nu.unit_id, nu.unit_name;

-- Pharmacy Dashboard
CREATE OR REPLACE VIEW vw_pharmacy_dashboard AS
WITH medication_orders AS (
    SELECT 
        pl.unit_id,
        o.order_id,
        o.priority,
        o.order_status,
        o.order_datetime,
        od.detail_value as medication_type
    FROM "order" o
    JOIN patient_location pl ON o.visit_id = pl.visit_id
    JOIN order_detail od ON o.order_id = od.order_id
    WHERE o.order_type = 'MEDICATION'
    AND pl.is_current = true
)
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE 
        WHEN mo.order_status = 'PENDING' THEN mo.order_id 
    END) as pending_orders,
    COUNT(DISTINCT CASE 
        WHEN mo.priority = 'STAT' AND mo.order_status = 'PENDING' 
        THEN mo.order_id 
    END) as pending_stat_orders,
    AVG(CASE 
        WHEN mo.order_status = 'COMPLETED'
        THEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - mo.order_datetime)) / 60 
    END) as avg_turnaround_mins,
    STRING_AGG(DISTINCT CASE 
        WHEN mo.priority = 'STAT' AND mo.order_status = 'PENDING'
        THEN mo.medication_type 
    END, ', ') as pending_stat_medications
FROM nursing_unit nu
LEFT JOIN medication_orders mo ON nu.unit_id = mo.unit_id
GROUP BY nu.unit_id, nu.unit_name;

-- Social Worker Dashboard
CREATE OR REPLACE VIEW vw_social_work_dashboard AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'SOCIAL_WORK_CONSULT' AND o.order_status = 'PENDING' 
        THEN o.order_id 
    END) as pending_consults,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'DISCHARGE_PLANNING' AND o.order_status = 'IN_PROGRESS' 
        THEN o.order_id 
    END) as active_discharge_planning,
    COUNT(DISTINCT CASE 
        WHEN ce.event_type = 'PSYCHOSOCIAL_ASSESSMENT' 
        AND ce.event_datetime >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
        THEN ce.event_id 
    END) as assessments_24h,
    STRING_AGG(DISTINCT CASE 
        WHEN od.detail_type = 'PLACEMENT_TYPE' AND o.order_status = 'PENDING'
        THEN od.detail_value 
    END, ', ') as pending_placements
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN order_detail od ON o.order_id = od.order_id
LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id
GROUP BY nu.unit_id, nu.unit_name;

-- View for expected admissions and discharges next 24 hours
CREATE OR REPLACE VIEW vw_24hr_movement_forecast AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'ADMISSION' AND o.order_status = 'PENDING' 
        AND o.start_datetime BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '24 hours'
        THEN o.order_id 
    END) as expected_admissions,
    COUNT(DISTINCT CASE 
        WHEN pv.expected_discharge_date BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '24 hours'
        THEN pv.visit_id 
    END) as expected_discharges,
    nu.total_beds - COUNT(DISTINCT pl.visit_id) as current_available_beds
FROM nursing_unit nu
LEFT JOIN patient_location pl ON 
    nu.unit_id = pl.unit_id AND 
    pl.is_current = true
LEFT JOIN patient_visit pv ON 
    pl.visit_id = pv.visit_id
LEFT JOIN "order" o ON 
    nu.unit_id = (SELECT pl2.unit_id 
                  FROM patient_location pl2 
                  WHERE pl2.visit_id = o.visit_id 
                  AND pl2.is_current = true)
GROUP BY nu.unit_id, nu.unit_name, nu.total_beds;

-- View for average length of stay by unit and admission type
CREATE OR REPLACE VIEW vw_unit_los_metrics AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    pv.admission_type,
    COUNT(DISTINCT pv.visit_id) as total_visits,
    ROUND(AVG(los.current_los_days), 1) as avg_los,
    ROUND(AVG(CASE WHEN los.los_variance_days > 0 THEN los.los_variance_days END), 1) as avg_positive_variance,
    ROUND(AVG(CASE WHEN los.los_variance_days < 0 THEN los.los_variance_days END), 1) as avg_negative_variance
FROM nursing_unit nu
JOIN patient_location pl ON 
    nu.unit_id = pl.unit_id
JOIN patient_visit pv ON 
    pl.visit_id = pv.visit_id
JOIN length_of_stay los ON 
    pv.visit_id = los.visit_id
WHERE los.calculation_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY nu.unit_id, nu.unit_name, pv.admission_type;

-- View for bed cleaning turnaround times
CREATE OR REPLACE VIEW vw_bed_turnover_metrics AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    DATE(pl.end_datetime) as turnover_date,
    COUNT(*) as total_turnovers,
    ROUND(AVG(EXTRACT(EPOCH FROM (
        LEAD(pl.start_datetime) OVER (PARTITION BY pl.room, pl.bed ORDER BY pl.end_datetime) - pl.end_datetime
    )) / 3600), 1) as avg_turnover_hours
FROM nursing_unit nu
JOIN patient_location pl ON 
    nu.unit_id = pl.unit_id
WHERE 
    pl.end_datetime IS NOT NULL
    AND pl.end_datetime >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY nu.unit_id, nu.unit_name, DATE(pl.end_datetime);

-- View for patient acuity distribution by unit
CREATE OR REPLACE VIEW vw_unit_acuity_distribution AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    ce.severity as acuity_level,
    COUNT(DISTINCT pl.visit_id) as patient_count,
    ROUND(COUNT(DISTINCT pl.visit_id)::NUMERIC / 
          NULLIF(SUM(COUNT(DISTINCT pl.visit_id)) OVER (PARTITION BY nu.unit_id), 0) * 100, 1) as percentage
FROM nursing_unit nu
LEFT JOIN patient_location pl ON 
    nu.unit_id = pl.unit_id AND 
    pl.is_current = true
LEFT JOIN clinical_event ce ON 
    pl.visit_id = ce.visit_id
WHERE 
    ce.event_type = 'ACUITY_ASSESSMENT'
    AND ce.event_datetime >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY nu.unit_id, nu.unit_name, ce.severity;

-- View for pending orders by type and priority
CREATE OR REPLACE VIEW vw_pending_orders_summary AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    o.order_type,
    o.priority,
    COUNT(*) as order_count,
    MIN(o.order_datetime) as oldest_order_datetime,
    ROUND(AVG(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - o.order_datetime)) / 3600), 1) as avg_order_age_hours
FROM nursing_unit nu
JOIN patient_location pl ON 
    nu.unit_id = pl.unit_id AND 
    pl.is_current = true
JOIN "order" o ON 
    pl.visit_id = o.visit_id
WHERE 
    o.order_status = 'PENDING'
GROUP BY nu.unit_id, nu.unit_name, o.order_type, o.priority
ORDER BY nu.unit_name, o.priority DESC, order_count DESC;

-- Specialized Operational Metric Views

-- Isolation room utilization and availability
CREATE OR REPLACE VIEW vw_isolation_metrics AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(CASE WHEN od.detail_type = 'ISOLATION_TYPE' THEN pl.location_id END) as total_isolation_patients,
    STRING_AGG(DISTINCT od.detail_value, ', ') as isolation_types,
    COUNT(DISTINCT CASE 
        WHEN pl.status = 'available' AND od.detail_type = 'ROOM_TYPE' 
        AND od.detail_value = 'ISOLATION' THEN pl.location_id 
    END) as available_isolation_rooms
FROM nursing_unit nu
LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN order_detail od ON o.order_id = od.order_id
GROUP BY nu.unit_id, nu.unit_name;

-- Equipment utilization and requirements
CREATE OR REPLACE VIEW vw_equipment_utilization AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    od.detail_value as equipment_type,
    COUNT(*) as in_use_count,
    SUM(CASE WHEN o.order_status = 'PENDING' THEN 1 ELSE 0 END) as pending_requests
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
JOIN "order" o ON pl.visit_id = o.visit_id
JOIN order_detail od ON o.order_id = od.order_id
WHERE od.detail_type = 'EQUIPMENT'
GROUP BY nu.unit_id, nu.unit_name, od.detail_value;

-- Patient mobility status distribution
CREATE OR REPLACE VIEW vw_mobility_status AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    ce.status as mobility_status,
    COUNT(*) as patient_count
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
JOIN clinical_event ce ON pl.visit_id = ce.visit_id
WHERE ce.event_type = 'MOBILITY_ASSESSMENT'
AND ce.event_datetime >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY nu.unit_id, nu.unit_name, ce.status;

-- Trending Analysis Views

-- Weekly admission patterns
CREATE OR REPLACE VIEW vw_weekly_admission_patterns AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    DATE_TRUNC('week', ps.status_datetime) as week_start,
    EXTRACT(DOW FROM ps.status_datetime) as day_of_week,
    EXTRACT(HOUR FROM ps.status_datetime) as hour_of_day,
    COUNT(*) as admission_count,
    AVG(COUNT(*)) OVER (
        PARTITION BY nu.unit_id, EXTRACT(DOW FROM ps.status_datetime), 
        EXTRACT(HOUR FROM ps.status_datetime)
        ORDER BY DATE_TRUNC('week', ps.status_datetime) 
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) as rolling_4_week_avg
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id
JOIN patient_status ps ON pl.visit_id = ps.visit_id
WHERE ps.status_type = 'ADMISSION'
AND ps.status_datetime >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('week', ps.status_datetime),
         EXTRACT(DOW FROM ps.status_datetime), EXTRACT(HOUR FROM ps.status_datetime);

-- Monthly LOS trends
CREATE OR REPLACE VIEW vw_monthly_los_trends AS
SELECT 
    nu.unit_id,
    nu.unit_name,
    DATE_TRUNC('month', pv.admission_date) as month,
    pv.admission_type,
    COUNT(DISTINCT pv.visit_id) as total_visits,
    ROUND(AVG(los.current_los_days), 1) as avg_los,
    ROUND(STDDEV(los.current_los_days), 1) as los_stddev,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY los.current_los_days) as los_median
FROM nursing_unit nu
JOIN patient_location pl ON nu.unit_id = pl.unit_id
JOIN patient_visit pv ON pl.visit_id = pv.visit_id
JOIN length_of_stay los ON pv.visit_id = los.visit_id
WHERE pv.admission_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY nu.unit_id, nu.unit_name, DATE_TRUNC('month', pv.admission_date), pv.admission_type;

-- Bed occupancy trends
CREATE OR REPLACE VIEW vw_occupancy_trends AS
SELECT 
    unit_id,
    unit_name,
    DATE_TRUNC('hour', census_datetime) as hour,
    AVG(occupied_beds::float / NULLIF(total_beds, 0) * 100) as avg_occupancy_rate,
    MAX(occupied_beds::float / NULLIF(total_beds, 0) * 100) as peak_occupancy_rate,
    AVG(pending_admissions) as avg_pending_admissions,
    AVG(pending_discharges) as avg_pending_discharges
FROM bed_census
WHERE census_datetime >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY unit_id, unit_name, DATE_TRUNC('hour', census_datetime);

-- Role-Specific Views

-- Charge Nurse Dashboard
CREATE OR REPLACE VIEW vw_charge_nurse_dashboard AS
WITH staffing_summary AS (
    SELECT 
        nu.unit_id,
        COUNT(DISTINCT CASE WHEN ct.role = 'RN' THEN ct.provider_id END) as rn_count,
        COUNT(DISTINCT CASE WHEN ct.role = 'CNA' THEN ct.provider_id END) as cna_count,
        COUNT(DISTINCT pl.visit_id) as patient_count
    FROM nursing_unit nu
    LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
    LEFT JOIN clinical_team ct ON pl.visit_id = ct.visit_id
    WHERE ct.end_datetime IS NULL
    GROUP BY nu.unit_id
)
SELECT 
    nu.unit_id,
    nu.unit_name,
    ss.rn_count,
    ss.cna_count,
    ss.patient_count,
    COUNT(DISTINCT CASE WHEN ce.severity IN ('HIGH', 'CRITICAL') THEN pl.visit_id END) as high_acuity_count,
    COUNT(DISTINCT CASE WHEN o.priority = 'STAT' AND o.order_status = 'PENDING' THEN o.order_id END) as pending_stat_orders,
    COUNT(DISTINCT CASE 
        WHEN pv.expected_discharge_date = CURRENT_DATE THEN pv.visit_id 
    END) as todays_discharges
FROM nursing_unit nu
JOIN staffing_summary ss ON nu.unit_id = ss.unit_id
LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN clinical_event ce ON pl.visit_id = ce.visit_id 
    AND ce.event_type = 'ACUITY_ASSESSMENT'
    AND ce.event_datetime >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
LEFT JOIN patient_visit pv ON pl.visit_id = pv.visit_id
GROUP BY nu.unit_id, nu.unit_name, ss.rn_count, ss.cna_count, ss.patient_count;

-- Bed Manager Dashboard
CREATE OR REPLACE VIEW vw_bed_manager_dashboard AS
WITH pending_placements AS (
    SELECT 
        o.order_type,
        o.priority,
        o.order_datetime,
        od.detail_value as required_unit_type,
        ROW_NUMBER() OVER (PARTITION BY o.visit_id ORDER BY o.order_datetime DESC) as rn
    FROM "order" o
    JOIN order_detail od ON o.order_id = od.order_id
    WHERE o.order_type = 'BED_PLACEMENT'
    AND o.order_status = 'PENDING'
)
SELECT 
    nu.unit_id,
    nu.unit_name,
    nu.total_beds,
    COUNT(DISTINCT CASE WHEN pl.status = 'occupied' THEN pl.location_id END) as occupied_beds,
    COUNT(DISTINCT CASE WHEN pl.status = 'available' THEN pl.location_id END) as available_beds,
    COUNT(DISTINCT CASE WHEN pl.status = 'blocked' THEN pl.location_id END) as blocked_beds,
    COUNT(DISTINCT CASE 
        WHEN pp.required_unit_type = nu.unit_type AND pp.rn = 1 
        THEN pp.order_type 
    END) as pending_placements,
    COUNT(DISTINCT CASE 
        WHEN pv.expected_discharge_date <= CURRENT_DATE + INTERVAL '4 hours'
        THEN pv.visit_id 
    END) as upcoming_discharges
FROM nursing_unit nu
LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id AND pl.is_current = true
LEFT JOIN pending_placements pp ON nu.unit_type = pp.required_unit_type
LEFT JOIN patient_visit pv ON pl.visit_id = pv.visit_id
GROUP BY nu.unit_id, nu.unit_name, nu.total_beds;

-- Housekeeping Supervisor Dashboard
CREATE OR REPLACE VIEW vw_housekeeping_dashboard AS
WITH room_status AS (
    SELECT 
        pl.unit_id,
        pl.room,
        pl.bed,
        pl.status,
        pl.end_datetime,
        ROW_NUMBER() OVER (PARTITION BY pl.room, pl.bed ORDER BY pl.end_datetime DESC) as rn
    FROM patient_location pl
    WHERE pl.end_datetime >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
)
SELECT 
    nu.unit_id,
    nu.unit_name,
    COUNT(DISTINCT CASE WHEN rs.status = 'available' THEN rs.room || rs.bed END) as clean_ready_beds,
    COUNT(DISTINCT CASE 
        WHEN rs.status = 'occupied' AND rs.end_datetime IS NOT NULL 
        THEN rs.room || rs.bed 
    END) as pending_clean_beds,
    AVG(EXTRACT(EPOCH FROM (
        LEAD(pl.start_datetime) OVER (PARTITION BY pl.room, pl.bed ORDER BY pl.end_datetime) 
        - pl.end_datetime
    )) / 60) as avg_turnover_minutes,
    COUNT(DISTINCT CASE 
        WHEN o.order_type = 'TERMINAL_CLEAN' AND o.order_status = 'PENDING' 
        THEN o.order_id 
    END) as pending_terminal_cleans
FROM nursing_unit nu
LEFT JOIN room_status rs ON nu.unit_id = rs.unit_id AND rs.rn = 1
LEFT JOIN patient_location pl ON nu.unit_id = pl.unit_id
LEFT JOIN "order" o ON pl.visit_id = o.visit_id
GROUP BY nu.unit_id, nu.unit_name;

-- Create Update Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update_updated_at_column trigger to all tables
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('
            CREATE TRIGGER update_updated_at_timestamp
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        ', t);
    END LOOP;
END;
$$ language 'plpgsql';

-- Create location history trigger
CREATE OR REPLACE FUNCTION update_location_history()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_current = true THEN
        UPDATE patient_location
        SET 
            is_current = false,
            end_datetime = NEW.start_datetime
        WHERE 
            visit_id = NEW.visit_id 
            AND is_current = true
            AND location_id != NEW.location_id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER maintain_location_history
BEFORE INSERT OR UPDATE ON patient_location
FOR EACH ROW
EXECUTE FUNCTION update_location_history();