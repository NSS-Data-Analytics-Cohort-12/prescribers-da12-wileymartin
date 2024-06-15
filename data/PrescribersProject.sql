1. 
    a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

	Select pct.total_claim_count, nppes_provider_last_org_name,pct.npi,pcr.npi,drug_name
	From prescription as pct
	Left Join prescriber AS Pcr
	ON pct.npi = pcr.npi
	ORDER BY total_claim_count DESC;

--- Coffey had the highest total # of claims totaled over all drugs. The NPI was 1912011792 and the total # of claims was 4538.

	

    b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
		
Select nppes_provider_first_name,nppes_provider_last_org_name,specialty_description,total_claim_count
	FROM prescription as pct
		LEFT JOIN prescriber as pcr
		ON pcr.npi = pct.npi;
		

2. 
    a. Which specialty had the most total number of claims (totaled over all drugs)?

	Select pcr.specialty_description,pct.total_claim_count, d.drug_name
	FROM drug as d
		LEFT JOIN prescription as pct
		ON pct.drug_name = d.drug_name
		LEFT JOIN prescriber as pcr
		ON pcr.npi = pct.npi
	WHERE pcr.specialty_description IS NOT NULL
	AND pct.total_claim_count IS NOT NULL
	ORDER BY total_claim_count DESC;

--- Family Practice

    b. Which specialty had the most total number of claims for opioids?
	Select pcr.specialty_description, COUNT(pct.drug_name), d.opioid_drug_flag
		FROM prescription as pct 
		INNER JOIN prescriber as pcr
		USING (npi)
		INNER JOIN drug as d
		ON pct.drug_name = d.drug_name
	WHERE d.opioid_drug_flag = 'Y'
	GROUP BY pcr.specialty_description,d.opioid_drug_flag
	ORDER BY COUNT(pct.drug_name)DESC;

---NURSE PRACTICTIONER

		

    c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

		Select psr.specialty_description, psc.total_claim_count,psr.description_flag
			FROM prescription as psc
			LEFT JOIN prescriber as psr 
			USING (npi);
		


    d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

3. 
    a. Which drug (generic_name) had the highest total drug cost?
	Select d.generic_name,CAST(pct.total_drug_cost AS MONEY)
		FROM drug as d
		LEFT JOIN prescription as pct
		ON pct.drug_name = d.drug_name
	WHERE total_drug_cost IS NOT NULL
	ORDER BY pct.total_drug_cost DESC;

--- "PIRFENIDONE"


    b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
	Select d.generic_name, ROUND(pct.total_drug_cost/365,2) as cost_per_day
		FROM drug AS d
		LEFT JOIN prescription as pct
		USING (drug_name)
	WHERE pct.total_drug_cost/365 IS NOT NULL
	ORDER BY cost_per_day DESC;

---"PIRFENIDONE"
4. 
    a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
	

	Select drug_name,opioid_drug_flag,antibiotic_drug_flag,CAST(total_drug_cost AS money),
	CASE When opioid_drug_flag = 'Y' THEN 'opioid'
	     When antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
	FROM drug AS d
	LEFT JOIN prescription as pct
	USING (drug_name)
	WHERE total_drug_cost IS NOT NULL
	ORDER BY total_drug_cost DESC;

b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.   
		
Select drug_name,opioid_drug_flag,antibiotic_drug_flag,
	CASE When opioid_drug_flag = 'Y' THEN 'opioid'
	     When antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
	FROM drug;

--- Going down the list it appears that there is more cost in opiods than antibiotics

5. 
    a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
	Select 
		cbsa, 
		cbsaname AS location
	From cbsa AS cb
		Inner Join fips_county As fips
		ON cb.fipscounty = fips.fipscounty
	WHERE fips.state LIKE '%TN%';

--- I see 42 CBSAs are in TN 

    b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

	Select 
		cb.cbsaname, 
		p.population
	FROM cbsa As cb
		Inner Join fips_county As fip
		Using (fipscounty)
		Inner JOIN  population As p 
		Using (fipscounty) 
	Where p.population IS NOT NULL
	Group BY cb.cbsaname,p.population
	ORDER by population DESC;

---- "Memphis, TN-MS-AR" has the highest population of 937847
--- "Nashville-Davidson--Murfreesboro--Franklin, TN" has the lowest of 8773

    c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
Select fip.county,
		fip.state,
		p.population,
		cb.cbsa
FROM fips_county AS fip 
		LEFT JOIN population AS p 
		USING (fipscounty)
		LEFT JOIN cbsa AS cb
		USING (fipscounty)
WHERE p.population IS NOT NULL
AND cb.cbsa IS NULL
ORDER BY p.population DESC;

--- Sevier, TN with a population of 95,523

		
6. 
    a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
Select *
From prescription 
Where total_claim_count >= 3000
ORDER BY total_claim_count DESC;

--- total claim count is 4,538 and the drug name is "OXYCODONE HCL".

    b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
Select 
		p.drug_name,
		p.total_claim_count, 
		d.opioid_drug_flag
From prescription AS p 
		LEFT JOIN drug AS d 
		USING (drug_name)
Where p.total_claim_count >= 3000
ORDER BY total_claim_count DESC;


    c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

Select 
		p.drug_name,
		p.total_claim_count, 
		d.opioid_drug_flag,
		psc.nppes_provider_first_name,
		psc.nppes_provider_last_org_name
From prescription AS p 
		LEFT JOIN drug AS d 
		USING (drug_name)
		LEFT JOIN prescriber as psc
		USING (npi)
Where p.total_claim_count >= 3000
ORDER BY total_claim_count DESC;
		

7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

    a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

Select  psc.npi,
		psc.drug_name,
		psr.specialty_description,
		psr.nppes_provider_city,
		d.opioid_drug_flag
From prescription AS psc
		Left JOIN drug AS d
		on d.drug_name = psc.drug_name
		CROSS JOIN prescriber AS psr
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';


	
    b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
		
Select  psc.npi,
		psr.nppes_provider_last_org_name,
		COUNT(psc.drug_name),
		psr.specialty_description,
		psr.nppes_provider_city,
		d.opioid_drug_flag,
		d.drug_name
From prescription AS psc
		FUll Join drug AS d
		ON d.drug_name = psc.drug_name
		FULL JOIN prescriber as psr
		ON psr.npi=psc.npi
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY d.drug_name,psr.nppes_provider_last_org_name, psr.npi,psc.npi,psr.specialty_description,psr.nppes_provider_city,d.opioid_drug_flag;



			

    c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.


