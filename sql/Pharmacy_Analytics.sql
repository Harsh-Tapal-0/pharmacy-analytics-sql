USE pharmacy_analytics;

DROP TABLE pharmacy_prescriptions;

CREATE TABLE pharmacy_prescriptions (
    drug_name VARCHAR(255),
    reporting_year INT,
    drug_class VARCHAR(255),
    brand_generic VARCHAR(50),
    payer_type VARCHAR(50),
    prescription_count BIGINT
);

SHOW TABLES;
DESCRIBE pharmacy_prescriptions;

SELECT COUNT(*) AS total_rows
FROM bi_snapshot_pharmacy_15008;
SELECT *
FROM bi_snapshot_pharmacy_15008
LIMIT 10;
DESCRIBE bi_snapshot_pharmacy_15008;

DROP TABLE pharmacy_prescriptions;

RENAME TABLE bi_snapshot_pharmacy_15008
TO pharmacy_prescriptions;

SELECT COUNT(*) AS total_rows
FROM pharmacy_prescriptions;

SELECT
    COUNT(*) AS total_rows,
    SUM(drug_name IS NULL) AS missing_drug,
    SUM(reporting_year IS NULL) AS missing_year,
    SUM(drug_class IS NULL) AS missing_class,
    SUM(brand_generic IS NULL) AS missing_brand_generic,
    SUM(payer_type IS NULL) AS missing_payer,
    SUM(prescription_count IS NULL) AS missing_prescriptions
FROM pharmacy_prescriptions;

SELECT DISTINCT reporting_year
FROM pharmacy_prescriptions
ORDER BY reporting_year;

SELECT reporting_year,
SUM(prescription_count) AS total_prescriptions FROM pharmacy_prescriptions GROUP BY reporting_year ORDER BY reporting_year;

SELECT payer_type,
SUM(prescription_count) AS total_prescriptions FROM pharmacy_prescriptions GROUP BY payer_type ORDER BY payer_type;

SELECT payer_type,
COUNT(prescription_count) AS number_of_records FROM pharmacy_prescriptions GROUP BY payer_type ORDER BY payer_type;

SELECT DISTINCT payer_type FROM pharmacy_prescriptions;

SELECT DISTINCT brand_generic FROM pharmacy_prescriptions;

SELECT
    MIN(prescription_count) AS minimum_prescriptions,
    MAX(prescription_count) AS maximum_prescriptions,
    SUM(prescription_count) AS total_prescriptions
FROM pharmacy_prescriptions;

SELECT
    COUNT(DISTINCT drug_name) AS unique_drugs,
    COUNT(DISTINCT drug_class) AS unique_drug_classes
FROM pharmacy_prescriptions;

SELECT drug_class,
SUM(prescription_count) AS total_prescriptions FROM pharmacy_prescriptions GROUP BY drug_class ORDER BY total_prescriptions DESC LIMIT 5;

SELECT reporting_year,
SUM(prescription_count) AS total_prescriptions FROM pharmacy_prescriptions GROUP BY reporting_year ORDER BY reporting_year;

WITH yearly_totals AS (
    SELECT
        reporting_year,
        SUM(prescription_count) AS total_prescriptions
    FROM pharmacy_prescriptions
    GROUP BY reporting_year
)

SELECT
    reporting_year,
    total_prescriptions,
    LAG(total_prescriptions)
        OVER (ORDER BY reporting_year) AS previous_year_prescriptions
FROM yearly_totals
ORDER BY reporting_year;

WITH yearly_totals AS (
    SELECT
        reporting_year,
        SUM(prescription_count) AS total_prescriptions
    FROM pharmacy_prescriptions
    GROUP BY reporting_year
),

yearly_comparison AS (
    SELECT
        reporting_year,
        total_prescriptions,
        LAG(total_prescriptions)
            OVER (ORDER BY reporting_year) AS previous_year_prescriptions
    FROM yearly_totals
)

SELECT
    reporting_year,
    total_prescriptions,
    previous_year_prescriptions,
    total_prescriptions - previous_year_prescriptions
        AS year_over_year_change
FROM yearly_comparison
ORDER BY reporting_year;

WITH yearly_totals AS (
    SELECT
        reporting_year,
        SUM(prescription_count) AS total_prescriptions
    FROM pharmacy_prescriptions
    GROUP BY reporting_year
),

yearly_comparison AS (
    SELECT
        reporting_year,
        total_prescriptions,
        LAG(total_prescriptions)
            OVER (ORDER BY reporting_year) AS previous_year_prescriptions
    FROM yearly_totals
)

SELECT
    reporting_year,
    total_prescriptions,
    previous_year_prescriptions,
    
    ROUND(
        (
            total_prescriptions - previous_year_prescriptions
        ) / previous_year_prescriptions * 100,
        2
    ) AS yoy_percentage_change

FROM yearly_comparison
ORDER BY reporting_year;

WITH payer_totals AS (
    SELECT
        payer_type,
        SUM(prescription_count) AS total_prescriptions
    FROM pharmacy_prescriptions
    GROUP BY payer_type
)
SELECT
    payer_type,
    total_prescriptions,
    ROUND(
        total_prescriptions /
        (SELECT SUM(total_prescriptions) FROM payer_totals) * 100,
        2
    ) AS percentage_of_total
FROM payer_totals
ORDER BY percentage_of_total DESC;






