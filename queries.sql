-- Create table to store budget allocation details with additional financial metrics and dynamic attributes
CREATE TABLE budget_allocation (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(255),
    allocated_budget DECIMAL(15, 2),
    spent_budget DECIMAL(15, 2),
    remaining_budget DECIMAL(15, 2) AS (allocated_budget - spent_budget) STORED,
    fiscal_year INT,
    region VARCHAR(100),
    capital_expenses DECIMAL(15, 2),
    operating_expenses DECIMAL(15, 2),
    capital_expense_ratio DECIMAL(5, 2) AS (capital_expenses / allocated_budget * 100) STORED,
    operating_expense_ratio DECIMAL(5, 2) AS (operating_expenses / allocated_budget * 100) STORED
);

-- Insert data into budget_allocation with additional metrics
INSERT INTO budget_allocation (department_id, department_name, allocated_budget, spent_budget, fiscal_year, region, capital_expenses, operating_expenses)
VALUES
(1, 'Marketing', 550000.00, 240000.00, 2025, 'North America', 100000.00, 140000.00),
(2, 'Sales', 320000.00, 175000.00, 2025, 'Europe', 60000.00, 115000.00),
(3, 'Research and Development', 420000.00, 200000.00, 2025, 'Asia', 120000.00, 80000.00),
(4, 'Operations', 380000.00, 190000.00, 2025, 'North America', 70000.00, 120000.00),
(5, 'IT', 500000.00, 250000.00, 2025, 'Global', 150000.00, 100000.00),
(6, 'HR', 200000.00, 120000.00, 2024, 'North America', 40000.00, 80000.00),
(7, 'Finance', 300000.00, 180000.00, 2024, 'Europe', 50000.00, 100000.00);

-- Create table to store ROI performance insights with campaign categorization and financial metrics
CREATE TABLE roi_performance (
    campaign_id INT PRIMARY KEY,
    department_name VARCHAR(255),
    campaign_name VARCHAR(255),
    investment DECIMAL(15, 2),
    returns DECIMAL(15, 2),
    roi DECIMAL(15, 2) AS ((returns - investment) / investment * 100) STORED,
    start_date DATE,
    end_date DATE,
    fiscal_year INT,
    campaign_type VARCHAR(50),
    campaign_channel VARCHAR(50),
    conversion_rate DECIMAL(5, 2),
    cost_per_acquisition DECIMAL(15, 2)
);

-- Insert data into roi_performance with additional metrics and campaign details
INSERT INTO roi_performance (campaign_id, department_name, campaign_name, investment, returns, start_date, end_date, fiscal_year, campaign_type, campaign_channel, conversion_rate, cost_per_acquisition)
VALUES
(101, 'Marketing', 'Product Launch', 120000.00, 190000.00, '2025-01-01', '2025-03-31', 2025, 'Launch', 'Digital', 15.5, 200.00),
(102, 'Sales', 'Holiday Campaign', 85000.00, 135000.00, '2025-11-01', '2025-12-31', 2025, 'Seasonal', 'TV', 10.3, 150.00),
(103, 'Research and Development', 'Market Expansion', 150000.00, 220000.00, '2025-06-01', '2025-09-30', 2025, 'Expansion', 'Digital', 20.1, 250.00),
(104, 'Operations', 'Efficiency Optimization', 60000.00, 95000.00, '2025-04-01', '2025-06-30', 2025, 'Efficiency', 'Print', 5.4, 180.00),
(105, 'IT', 'Cybersecurity Initiative', 70000.00, 105000.00, '2025-03-01', '2025-05-31', 2025, 'Security', 'Digital', 12.7, 210.00),
(106, 'HR', 'Employee Engagement', 50000.00, 70000.00, '2024-09-01', '2024-11-30', 2024, 'Engagement', 'In-person', 8.2, 160.00),
(107, 'Finance', 'Cost Reduction', 80000.00, 120000.00, '2024-07-01', '2024-09-30', 2024, 'Reduction', 'TV', 7.9, 140.00);

-- Complex query to calculate budget allocation, ROI, and financial metrics across departments, regions, and fiscal years
WITH budget_summary AS (
    SELECT
        b.department_name,
        b.fiscal_year,
        b.region,
        SUM(b.allocated_budget) AS total_allocated,
        SUM(b.spent_budget) AS total_spent,
        SUM(b.remaining_budget) AS total_remaining,
        SUM(b.capital_expenses) AS total_capital_expenses,
        SUM(b.operating_expenses) AS total_operating_expenses,
        AVG(b.capital_expense_ratio) AS avg_capital_expense_ratio,
        AVG(b.operating_expense_ratio) AS avg_operating_expense_ratio
    FROM
        budget_allocation b
    GROUP BY
        b.department_name, b.fiscal_year, b.region
),
roi_summary AS (
    SELECT
        r.department_name,
        r.fiscal_year,
        r.region,
        SUM(r.investment) AS total_investment,
        SUM(r.returns) AS total_returns,
        AVG(r.roi) AS average_roi,
        SUM(r.conversion_rate) AS total_conversion_rate,
        AVG(r.cost_per_acquisition) AS avg_cost_per_acquisition
    FROM
        roi_performance r
    GROUP BY
        r.department_name, r.fiscal_year, r.region
),
performance_analysis AS (
    SELECT
        b.department_name,
        b.fiscal_year,
        b.region,
        b.total_allocated,
        b.total_spent,
        b.total_remaining,
        b.total_capital_expenses,
        b.total_operating_expenses,
        b.avg_capital_expense_ratio,
        b.avg_operating_expense_ratio,
        r.total_investment,
        r.total_returns,
        r.average_roi,
        r.total_conversion_rate,
        r.avg_cost_per_acquisition,
        CASE
            WHEN b.total_allocated > 0 THEN (r.total_returns - r.total_investment) / b.total_allocated * 100
            ELSE 0
        END AS roi_percentage,
        CASE
            WHEN b.total_allocated > 0 THEN (b.total_spent / b.total_allocated) * 100
            ELSE 0
        END AS spend_percentage,
        CASE
            WHEN r.total_investment > 0 THEN (r.total_returns - r.total_investment) / r.total_investment * 100
            ELSE 0
        END AS campaign_roi_percentage
    FROM
        budget_summary b
    JOIN
        roi_summary r
    ON
        b.department_name = r.department_name AND b.fiscal_year = r.fiscal_year AND b.region = r.region
)
SELECT
    p.department_name,
    p.fiscal_year,
    p.region,
    p.total_allocated,
    p.total_spent,
    p.total_remaining,
    p.total_capital_expenses,
    p.total_operating_expenses,
    p.avg_capital_expense_ratio,
    p.avg_operating_expense_ratio,
    p.total_investment,
    p.total_returns,
    p.average_roi,
    p.total_conversion_rate,
    p.avg_cost_per_acquisition,
    p.roi_percentage,
    p.spend_percentage,
    p.campaign_roi_percentage,
    ROW_NUMBER() OVER (PARTITION BY p.department_name, p.fiscal_year ORDER BY p.roi_percentage DESC) AS rank_by_roi,
    PERCENT_RANK() OVER (PARTITION BY p.fiscal_year ORDER BY p.campaign_roi_percentage DESC) AS percentile_by_campaign_roi
FROM
    performance_analysis p
ORDER BY
    p.department_name, p.fiscal_year, p.region;

-- Advanced rolling average for ROI over time (e.g., quarterly ROI average over previous 4 quarters)
WITH rolling_roi AS (
    SELECT
        r.department_name,
        r.fiscal_year,
        r.region,
        r.roi,
        AVG(r.roi) OVER (PARTITION BY r.department_name ORDER BY r.fiscal_year ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS rolling_avg_roi
    FROM
        roi_performance r
)
SELECT
    r.department_name,
    r.fiscal_year,
    r.region,
    r.roi,
    r.rolling_avg_roi,
    b.total_allocated,
    b.total_spent,
    b.total_remaining
FROM
    rolling_roi r
JOIN
    budget_summary b
ON
    r.department_name = b.department_name AND r.fiscal_year = b.fiscal_year
ORDER BY
    r.department_name, r.fiscal_year, r.region;
