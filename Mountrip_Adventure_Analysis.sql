-- 1. Revenue Analysis

SELECT b.booking_id,
      p.package_name,
    b.num_people,
    b.nights,
    b.amount AS revenue,
    (pc.travel_cost_per_person * b.num_people) AS travel_cost,
    (pc.hotel_cost_per_night * b.nights * b.num_people) AS hotel_cost,
	(pc.worker_cost_per_day * b.nights) AS worker_cost,
    (pc.food_cost_per_person * b.num_people) AS guest_food_cost,
--  PERSONAL FOOD COST
    CASE 
        WHEN p.package_name = 'Tungnath' THEN 0
        ELSE (pc.personal_food_cost_per_day * b.nights)
    END AS personal_food_cost,
-- TOTAL COST
        (
        (pc.travel_cost_per_person * b.num_people) +
        (pc.hotel_cost_per_night * b.nights * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        CASE 
            WHEN p.package_name = 'Tungnath' THEN 0
            ELSE (pc.personal_food_cost_per_day * b.nights)
        END
    ) AS total_cost,
-- FINAL PROFIT
    (b.amount -
        (
            (pc.travel_cost_per_person * b.num_people) +
            (pc.hotel_cost_per_night * b.nights * b.num_people) +
            (pc.worker_cost_per_day * b.nights) +
            (pc.food_cost_per_person * b.num_people) +
            CASE 
                WHEN p.package_name = 'Tungnath' THEN 0
                ELSE (pc.personal_food_cost_per_day * b.nights)
            END
        )
    ) AS net_profit

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id;


#--------------------------------------------------------------------------

-- 2. Total Revenue & Profit 

SELECT 
    SUM(b.amount) AS total_revenue,
    SUM(
        (pc.travel_cost_per_person * b.num_people) +
        (pc.hotel_cost_per_night * b.nights * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        CASE 
            WHEN p.package_name = 'Tungnath' THEN 0
            ELSE (pc.personal_food_cost_per_day * b.nights)
        END
    ) AS total_cost,
    SUM(b.amount) - 
    SUM(
        (pc.travel_cost_per_person * b.num_people) +
        (pc.hotel_cost_per_night * b.nights * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        CASE 
            WHEN p.package_name = 'Tungnath' THEN 0
            ELSE (pc.personal_food_cost_per_day * b.nights)
        END
    ) AS total_profit

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id;



#--------------------------------------------------------------------------------------

-- 3. Package Analysis (which package earns more & which is risky)
 
 
 SELECT 
    p.package_name,
    COUNT(*) AS total_bookings,
    SUM(b.amount) AS revenue,
    SUM(b.amount) - 
    SUM(
        (pc.travel_cost_per_person * b.num_people) +
        (pc.hotel_cost_per_night * b.nights * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        CASE 
            WHEN p.package_name = 'Tungnath' THEN 0
            ELSE (pc.personal_food_cost_per_day * b.nights)
        END
    ) AS profit

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id

GROUP BY p.package_name
ORDER BY profit DESC;

#-----------------------------------------------------------------------------------

-- 4. Monthly Trend Analysis

SELECT 
    MONTH(b.travel_date) AS month,
    COUNT(*) AS total_bookings,
    SUM(b.amount) AS total_revenue,

    SUM(b.amount) - 
    SUM(
        (pc.travel_cost_per_person * b.num_people) +
        (pc.hotel_cost_per_night * b.nights * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        
        CASE 
            WHEN p.package_name = 'Tungnath' THEN 0
            ELSE (pc.personal_food_cost_per_day * b.nights)
        END
    ) AS total_profit

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id

GROUP BY MONTH(b.travel_date)
ORDER BY month;

#-------------------------------------------------------------------------------

-- 5. Group Size Analysis (do groups give more profit)


SELECT 
    b.num_people,
    COUNT(*) AS bookings,
    AVG(b.amount) AS avg_revenue,
    AVG(
        b.amount -
        (
            (pc.travel_cost_per_person * b.num_people) +
            (pc.hotel_cost_per_night * b.nights * b.num_people) +
            (pc.worker_cost_per_day * b.nights) +
            (pc.food_cost_per_person * b.num_people) +
            CASE 
                WHEN p.package_name = 'Tungnath' THEN 0
                ELSE (pc.personal_food_cost_per_day * b.nights)
            END
        )
    ) AS avg_profit

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id

GROUP BY b.num_people
ORDER BY b.num_people;


#--------------------------------------------------------------------------------------

-- 6. Loss Analysis ( Which day was not profitable)


SELECT 
    p.package_name,
    b.booking_id,
    b.amount,
    b.amount -
    (
	    (pc.travel_cost_per_person * b.num_people) +
        (pc.hotel_cost_per_night * b.nights * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        CASE 
            WHEN p.package_name = 'Tungnath' THEN 0
            ELSE (pc.personal_food_cost_per_day * b.nights)
        END
    ) AS profit

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id

WHERE 
    (b.amount -
        (
            (pc.travel_cost_per_person * b.num_people) +
            (pc.hotel_cost_per_night * b.nights * b.num_people) +
            (pc.worker_cost_per_day * b.nights) +
            (pc.food_cost_per_person * b.num_people) +
            CASE 
                WHEN p.package_name = 'Tungnath' THEN 0
                ELSE (pc.personal_food_cost_per_day * b.nights)
            END
        )
    ) < 0;

#-----------------------------------------------------------------------------------------    
    
    
-- 7. Platform Analysis for Kedarnath (which platform brings more booking, more revenue & profit )
    
    SELECT 
    pl.platform_name,
    COUNT(*) AS bookings,
    SUM(b.amount) AS revenue,

    SUM(b.amount) - 
    SUM(
        (pc.travel_cost_per_person * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        (pc.personal_food_cost_per_day * b.nights)
    ) AS profit

FROM bookings b
JOIN platforms pl ON b.platform_id = pl.platform_id
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id

WHERE p.package_name = 'Kedarnath'

GROUP BY pl.platform_name
ORDER BY profit DESC;

# ------------------------------------------------------------------------


-- 8. Profit Margin By Package (Best package for profit )


SELECT 
    p.package_name,
    SUM(b.amount) AS revenue,

    ROUND(
        (SUM(b.amount) - 
        SUM(
            (pc.travel_cost_per_person * b.num_people) +
            (pc.hotel_cost_per_night * b.nights * b.num_people) +
            (pc.worker_cost_per_day * b.nights) +
            (pc.food_cost_per_person * b.num_people) +
            CASE 
                WHEN p.package_name = 'Tungnath' THEN 0
                ELSE (pc.personal_food_cost_per_day * b.nights)
            END
        )) / SUM(b.amount) * 100, 2
    ) AS profit_margin

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id

GROUP BY p.package_name
ORDER BY profit_margin DESC;

#---------------------------------------------------------------------------------------
-- 9. Loss Making Pattern Analysis( which type of booking causes loss)


SELECT 
    p.package_name,
    b.num_people,
    b.nights,
    COUNT(*) AS loss_cases

FROM bookings b
JOIN packages p ON b.package_id = p.package_id
JOIN package_costs pc ON p.package_id = pc.package_id

WHERE 
    b.amount -
    (
        (pc.travel_cost_per_person * b.num_people) +
        (pc.hotel_cost_per_night * b.nights * b.num_people) +
        (pc.worker_cost_per_day * b.nights) +
        (pc.food_cost_per_person * b.num_people) +
        CASE 
            WHEN p.package_name = 'Tungnath' THEN 0
            ELSE (pc.personal_food_cost_per_day * b.nights)
        END
    ) < 0

GROUP BY p.package_name, b.num_people, b.nights
ORDER BY loss_cases DESC;


