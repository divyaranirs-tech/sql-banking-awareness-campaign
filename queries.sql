CREATE TABLE bank_marketing (
    age NUMERIC,
    job VARCHAR(50),
    marital VARCHAR(20),
    education VARCHAR(30),
    default_status VARCHAR(10),
    balance NUMERIC,
    housing VARCHAR(10),
    loan VARCHAR(10),
    contact VARCHAR(20),
    DAY INT,
    MONTH VARCHAR(10),
    duration INT,
    campaign INT,
    pdays INT,
    previous INT,
    poutcome VARCHAR(20),
    subscribed VARCHAR(5)
);
SELECT * 
FROM public.bank_marketing;
--total customers
SELECT count( * )AS total_customers
 FROM public.bank_marketing;


--if the client subscribed term deposit
SELECT 
count(CASE WHEN subscribed='no'THEN 1 END) AS not_subscribed,
count(CASE WHEN subscribed='yes'THEN 1 END) AS subscribed
      FROM public.bank_marketing;
       
       
 --subscription rate
 SELECT
 (count(CASE WHEN subscribed='yes'THEN 1 END)*100.0/count( * ))::DECIMAL(5,2) AS subscription_rate 
 FROM public.bank_marketing;
 
 --by job
 SELECT job, 
 (count(CASE WHEN subscribed='yes'THEN 1 END)*100.0/count( * ))::DECIMAL(5,2) AS success_rate 
 FROM public.bank_marketing GROUP BY job ORDER BY job;
 
 --most balance by job
SELECT job,sum( balance)AS total_balance 
FROM public.bank_marketing 
GROUP BY job ORDER BY total_balance DESC LIMIT 1;

--least balance
SELECT job,sum( balance)AS total_balance 
FROM public.bank_marketing 
GROUP BY job ORDER BY total_balance LIMIT 1;
--SECOND LEAST
WITH job_balances AS (
    SELECT
        job,
        SUM(balance) AS total_balance,
        RANK() OVER (ORDER BY SUM(balance)) AS rnk
    FROM public.bank_marketing
    GROUP BY job
)
SELECT job, total_balance
FROM job_balances
WHERE rnk = 2;
--housing loan and personal loan
SELECT 
count( CASE WHEN housing='yes' THEN 1 END )AS housing_loan,
count( CASE WHEN loan='yes' THEN 1 END )AS personal_loan
FROM public.bank_marketing;

--both housing and personal loan
SELECT count( * )
FROM public.bank_marketing 
WHERE housing='yes' AND loan='yes';

--max balance
SELECT * 
FROM public.bank_marketing 
WHERE balance=(SELECT max(balance)
FROM public.bank_marketing);

   --new clients
SELECT "month",
count( CASE WHEN pdays=-1 THEN 1 END )AS new_clients 
FROM public.bank_marketing GROUP BY "month";
 
 --Relation between loan and subscription
 SELECT loan,count( * )AS total,
                       count(CASE WHEN subscribed='yes'THEN 1 END)AS subscribed,
                       (count(CASE WHEN subscribed='yes'THEN 1 END)*100.0/count( * ))::DECIMAL(5,2) AS subscription_rate
                       FROM public.bank_marketing GROUP BY loan ORDER BY loan;
                       
                       
                       
                       ---age and subscription
 SELECT 
        CASE
             WHEN age<30 THEN 'Under 30'
             WHEN age BETWEEN 30 AND 50 THEN '30-50'
             WHEN age>50 THEN 'above 50'
             
        END AS age_group,
        count( * ),                     
     count(CASE WHEN subscribed='yes'THEN 1 END)AS total_subscription
     FROM public.bank_marketing GROUP BY age_group;
     
     

--relation between total campaign and success monthwise
SELECT "month",sum( campaign )AS total_campaign,
                               count(CASE WHEN subscribed='yes'THEN 1 END)AS subscribed
                               
        FROM public.bank_marketing 
        GROUP BY "month"
        
        UNION ALL
        
        SELECT 
        
        'grand total' AS "month",
        count( * ),
        sum(CASE WHEN subscribed='yes'THEN 1 ELSE 0 END  )
        FROM public.bank_marketing;     
        

--total campaign
SELECT count(CASE WHEN campaign=1 THEN 1 END)AS single_contact,
       count(CASE WHEN campaign>1 THEN 1 END)AS multiple_contacts
     FROM public.bank_marketing;
     
     --successful campaign
SELECT count(CASE WHEN campaign=1 THEN 1 END)AS single_contact,
       count(CASE WHEN campaign>1 THEN 1 END)AS multiple_contacts
     FROM public.bank_marketing 
     WHERE subscribed='yes';
     
     

--previously failed and currently success
SELECT count( * )
FROM public.bank_marketing 
WHERE poutcome='failure' AND subscribed='yes';

--previously success currently failed
SELECT count( * )
FROM public.bank_marketing 
WHERE poutcome='success' AND subscribed='no';


--both time success
SELECT count( * )
FROM public.bank_marketing 
WHERE poutcome='success' AND subscribed='yes';


--success rate by contact method
SELECT contact,count(*)AS total,
count(CASE WHEN subscribed='yes'THEN 1 END)AS total_subscription,
(count(CASE WHEN subscribed='yes'THEN 1 END)*100.0/count( * ))::DECIMAL(5,2) AS subscription_rate
FROM public.bank_marketing 
GROUP BY contact;


--MOM CHANGE PERCENTAGE
 WITH monthly_data AS (
    SELECT
        CASE MONTH
            WHEN 'jan' THEN 1 WHEN 'feb' THEN 2 WHEN 'mar' THEN 3
            WHEN 'apr' THEN 4 WHEN 'may' THEN 5 WHEN 'jun' THEN 6
            WHEN 'jul' THEN 7 WHEN 'aug' THEN 8 WHEN 'sep' THEN 9
            WHEN 'oct' THEN 10 WHEN 'nov' THEN 11 WHEN 'dec' THEN 12
        END AS month_number,
        "month",
        COUNT(*) FILTER (WHERE subscribed = 'yes') AS subscriptions
    FROM bank_marketing
    GROUP BY "month"
)
SELECT
    "month",
    subscriptions,
    LAG(subscriptions) OVER (ORDER BY month_number) AS previous_month,
    ROUND(
        ( (subscriptions - LAG(subscriptions) OVER (ORDER BY month_number))::NUMERIC /
           NULLIF(LAG(subscriptions) OVER (ORDER BY month_number), 0) ) * 100,
        2
    ) AS mom_change_percent
FROM monthly_data
ORDER BY month_number;
