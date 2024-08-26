SET SQL_SAFE_UPDATES = 0;
ALTER TABLE customer_churn 
CHANGE COLUMN `Customer ID` CustomerID VARCHAR(255);
ALTER TABLE customer_churn 
CHANGE COLUMN `Number of Dependents` NoofDependents DECIMAL(10,2),
CHANGE COLUMN `Zip Code` Zipcode varchar (255);
DESCRIBE customer_churn;
ALTER TABLE customer_churn 
CHANGE COLUMN `Number of Referrals` NoofReferals int(255),
CHANGE COLUMN `Tenure in Months` Tenureinmonths int(255),
CHANGE COLUMN `Phone Service` PhoneService varchar(10),
CHANGE COLUMN `Avg Monthly Long Distance Charges` AvglongdisCharges varchar(255);

ALTER TABLE customer_churn
CHANGE COLUMN `Avg Monthly GB Download` AvgMonthlyGBDownload DECIMAL(10,2),
CHANGE COLUMN `Online Security` OnlineSecurity VARCHAR(10),
CHANGE COLUMN `Online Backup` OnlineBackup VARCHAR(10),
CHANGE COLUMN `Device Protection Plan` DeviceProtectionPlan VARCHAR(10),
CHANGE COLUMN `Premium Tech Support` PremiumTechSupport VARCHAR(10),
CHANGE COLUMN `Streaming TV` StreamingTV VARCHAR(10),
CHANGE COLUMN `Unlimited Data` UnlimitedData VARCHAR(10),
CHANGE COLUMN `Paperless Billing` PaperlessBilling VARCHAR(10),
CHANGE COLUMN `Payment Method` PaymentMethod VARCHAR(50),
CHANGE COLUMN `Monthly Charge` MonthlyCharge DECIMAL(10,2),
CHANGE COLUMN `Total Charges` TotalCharges DECIMAL(10,2),
CHANGE COLUMN `Total Refunds` TotalRefunds DECIMAL(10,2),
CHANGE COLUMN `Total Extra Data Charges` TotalExtraDataCharges DECIMAL(10,2),
CHANGE COLUMN `Total Long Distance Charges` TotalLongDistanceCharges DECIMAL(10,2),
CHANGE COLUMN `Total Revenue` TotalRevenue DECIMAL(10,2),
CHANGE COLUMN `Customer Status` CustomerStatus VARCHAR(50),
CHANGE COLUMN `Churn Category` ChurnCategory VARCHAR(50),
CHANGE COLUMN `Churn Reason` ChurnReason VARCHAR(255);

DESCRIBE customer_churn;

-- Total number of customers churned rate and age 
SELECT COUNT(*) AS total_customers FROM customer_churn;

-- Churned rate

SELECT 
    (COUNT(CASE WHEN CustomerStatus = 'Churned' THEN 1 END) / COUNT(*)) * 100 AS churn_rate 
FROM customer_churn;

-- Average age of churned customer

SELECT AVG(Age) AS avg_age_of_churned_customers
FROM customer_churn
WHERE CustomerStatus = 'Churned';

-- Discover the most common contract types among churned customers

SELECT Contract, COUNT(*) AS churn_count
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY Contract
ORDER BY churn_count DESC
LIMIT 1;

-- Analyze the distribution of monthly charges among churned customers
SELECT MonthlyCharge, COUNT(*) AS customer_count
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY MonthlyCharge
ORDER BY MonthlyCharge ASC;

-- Identify the contract types that are most prone to churn:
SELECT Contract, 
       (COUNT(CASE WHEN CustomerStatus = 'Churned' THEN 1 END) / COUNT(*)) * 100 AS churn_rate
FROM customer_churn
GROUP BY Contract
ORDER BY churn_rate DESC;

-- Identify customers with high total charges who have churned:
SELECT CustomerID, TotalCharges, CustomerStatus
FROM customer_churn
WHERE CustomerStatus = 'Churned'
ORDER BY TotalCharges DESC
LIMIT 10; -- we can adjust the limit as per need 

-- Calculate the total charges distribution for churned and non-churned customers:
SELECT 
    CustomerStatus, 
    COUNT(*) AS customer_count, 
    MIN(TotalCharges) AS min_total_charges, 
    MAX(TotalCharges) AS max_total_charges, 
    AVG(TotalCharges) AS avg_total_charges
FROM customer_churn
GROUP BY CustomerStatus;

-- Calculate the average monthly charges for different contract types among churned customers
SELECT Contract, AVG(MonthlyCharge) AS avg_monthly_charge
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY Contract;

-- Identify customers who have both online security and online backup services and have not churned

SELECT CustomerID, OnlineSecurity, OnlineBackup, CustomerStatus
FROM customer_churn
WHERE OnlineSecurity = 'Yes' 
AND OnlineBackup = 'Yes'
AND CustomerStatus != 'Churned';

-- Determine the most common combinations of services among churned customers

SELECT 
    CONCAT_WS(', ',
        IF(OnlineSecurity = 'Yes', 'Online Security', NULL),
        IF(OnlineBackup = 'Yes', 'Online Backup', NULL),
        IF(DeviceProtectionPlan = 'Yes', 'Device Protection Plan', NULL),
        IF(PremiumTechSupport = 'Yes', 'Premium Tech Support', NULL),
        IF(StreamingTV = 'Yes', 'Streaming TV', NULL),
        IF('Streaming Movies' = 'Yes', 'Streaming Movies', NULL),
        IF(UnlimitedData = 'Yes', 'Unlimited Data', NULL)
    ) AS service_combination,
    COUNT(*) AS customer_count
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY service_combination
ORDER BY customer_count DESC;

-- Identify the average total charges for customers grouped by gender and marital status
SELECT 
    Gender,
    Married,
    AVG(TotalCharges) AS avg_total_charges
FROM customer_churn
GROUP BY Gender, Married;

-- Calculate the average monthly charges for different age groups among churned customers

SELECT 
    CASE 
        WHEN Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        WHEN Age >= 65 THEN '65+'
        ELSE 'Unknown'
    END AS age_group,
    AVG(MonthlyCharge) AS avg_monthly_charges
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY age_group;

-- Determine the average age and total charges for customers with multiple lines and online backup

SELECT 
    AVG(Age) AS avg_age,
    AVG(TotalCharges) AS avg_total_charges
FROM customer_churn
WHERE 'Multiple Lines' = 'Yes' AND OnlineBackup = 'Yes';

-- Identify the contract types with the highest churn rate among senior citizens (age 65 and over)

SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    (SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS churn_rate
FROM customer_churn
WHERE Age >= 65
GROUP BY Contract
ORDER BY churn_rate DESC;

-- Calculate the average monthly charges for customers who have multiple lines and streaming TV

SELECT 
    AVG(MonthlyCharge) AS avg_monthly_charges
FROM customer_churn
WHERE 'Multiple Lines' = 'Yes' AND StreamingTV = 'Yes';

-- Identify customers who have the highest total revenue (top 5):
SELECT 
    CustomerID, 
    TotalCharges
FROM customer_churn
ORDER BY TotalCharges DESC
LIMIT 5;

-- Find the churn rate for customers with different payment methods

SELECT 
    PaymentMethod, 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    (SUM(CASE WHEN CustomerStatus = 'Churned' THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS churn_rate
FROM customer_churn
GROUP BY PaymentMethod
ORDER BY churn_rate DESC;

-- Calculate the total extra data charges for churned customers
SELECT 
    SUM(TotalExtraDataCharges) AS total_extra_data_charges
FROM customer_churn
WHERE CustomerStatus = 'Churned';

--  Identify the number of customers with paperless billing who have churned:

SELECT 
    COUNT(*) AS churned_with_paperless_billing
FROM customer_churn
WHERE PaperlessBilling = 'Yes' AND CustomerStatus = 'Churned';

-- Find the most common churn reasons and their frequencies

SELECT 
    ChurnReason, 
    COUNT(*) AS frequency
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY ChurnReason
ORDER BY frequency DESC;

-- Calculate the average monthly charges and total charges for customers who have churned, grouped by the number of dependents
SELECT 
    NoofDependents,
    AVG(MonthlyCharge) AS avg_monthly_charges,
    AVG(TotalCharges) AS avg_total_charges
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY NoofDependents;

-- Identify the customers who have churned and their contract duration in months (for monthly contracts)
SELECT 
    CustomerID, 
    Contract AS contract_duration_months
FROM customer_churn
WHERE CustomerStatus = 'Churned' AND Contract = 'Month-to-month';

-- Determine the average age and total charges for customers who have churned, grouped by internet service and phone service:
SELECT 
    'Internet Service',
    PhoneService,
    AVG(Age) AS avg_age,
    AVG(TotalCharges) AS avg_total_charges
FROM customer_churn
WHERE CustomerStatus = 'Churned'
GROUP BY 'Internet Service', PhoneService

DELIMITER $$

CREATE PROCEDURE CalculateChurnRate()
BEGIN
    DECLARE totalCustomers INT;
    DECLARE churnedCustomers INT;
    DECLARE churnRate DECIMAL(5, 2);
    
    -- Get total number of customers
    SELECT COUNT(*) INTO totalCustomers
    FROM customer_churn;
    
    -- Get total number of churned customers
    SELECT COUNT(*) INTO churnedCustomers
    FROM customer_churn
    WHERE CustomerStatus = 'Churned';
    
    -- Calculate churn rate
    SET churnRate = (churnedCustomers / totalCustomers) * 100;
    
    -- Output churn rate
    SELECT CONCAT('Churn Rate: ', churnRate, '%') AS ChurnRate;
    
END $$

DELIMITER ;

CALL CalculateChurnRate();


DELIMITER $$

CREATE PROCEDURE IdentifyHighValueAtRiskCustomers5(IN minTotalCharges DECIMAL(10,2), IN minMonthlyCharges DECIMAL(10,2))
BEGIN
    -- Select high-value customers at risk of churning
    SELECT CustomerID, Age, TotalCharges, MonthlyCharge, CustomerStatus
    FROM customer_churn
    WHERE TotalCharges >= minTotalCharges
    AND MonthlyCharge >= minMonthlyCharges
    AND CustomerStatus = 'At Risk';
END $$

DELIMITER ;

CALL IdentifyHighValueAtRiskCustomers5(1500, -5);