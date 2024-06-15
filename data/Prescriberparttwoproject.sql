1. Write a query which returns the total number of claims for these two groups. Your output should look like this: 

specialty_description         |total_claims|
------------------------------|------------|
Interventional Pain Management|       55906|
Pain Management               |       70853|

Select psr.specialty_description, SUM(psc.total_claim_count)
FROM prescription as psc 
		LEFT JOIN prescriber as psr 
		USING (npi)
WHERE specialty_description IN ('Interventional Pain Management', 'Pain Management')
GROUP BY specialty_description;



2. Now, lets say that we want our output to also include the total number of claims between these two groups. Combine two queries with the UNION keyword to accomplish this. Your output should look like this:

		specialty_description         |total_claims|
		------------------------------|------------|
                           			   |      126759|
		Interventional Pain Management|       55906|
		Pain Management               |       70853|

Select psr.specialty_description, SUM(psc.total_claim_count) AS total_claims
FROM prescription as psc 
		LEFT JOIN prescriber as psr 
		USING (npi)
WHERE specialty_description IN ('Interventional Pain Management', 'Pain Management')
GROUP BY specialty_description

UNION 
Select  '' specialty_description , COUNT(total_claim_count)
FROM prescription as psc
GROUP BY specialty_description;

3. Now, instead of using UNION, make use of GROUPING SETS (https://www.postgresql.org/docs/10/queries-table-expressions.html#QUERIES-GROUPING-SETS) to achieve the same output.

Select psr.specialty_description, SUM(psc.total_claim_count)
	From prescription AS psc
	LEFT JOIN prescriber as psr
	USING (npi)
WHERE specialty_description IN ('Interventional Pain Management', 'Pain Management')
Group BY Grouping Sets (specialty_description,());

4. In addition to comparing the total number of prescriptions by specialty, lets also bring in information about the number of opioid vs. non-opioid claims by these two specialties. Modify your query (still making use of GROUPING SETS so that your output also shows the total number of opioid claims vs. non-opioid claims by these two specialites:

specialty_description         |opioid_drug_flag|total_claims|
------------------------------|----------------|------------|
                              |                |      129726|
                              |Y               |       76143|
                              |N               |       53583|
Pain Management               |                |       72487|
Interventional Pain Management|                |       57239|

Select psr.specialty_description, SUM(pst.total_claim_count), d.opioid_drug_flag
	FROM drug as d 
	LEFT JOIN prescription as pst 
	USING (drug_name)
	LEFT JOIN prescriber as psr
	USING(npi)
WHERE specialty_description IN ('Pain Management','Interventional Pain Management')
GROUP BY Grouping SETS (specialty_description,opioid_drug_flag,());

5. Modify your query by replacing the GROUPING SETS with ROLLUP(opioid_drug_flag, specialty_description). How is the result different from the output from the previous query?
	
Select psr.specialty_description, SUM(pst.total_claim_count), d.opioid_drug_flag
	FROM drug as d 
	LEFT JOIN prescription as pst 
	USING (drug_name)
	LEFT JOIN prescriber as psr
	USING(npi)
WHERE specialty_description IN ('Pain Management','Interventional Pain Management')
GROUP BY Grouping SETS (ROLLUP(opioid_drug_flag,specialty_description));

--- Rollup is different because it returns the individual claim count for each instance of the specialty description instead of summing them up like before into one row. So it created a couple of subtotals fro, "Pain Management" and "Interventional Pain Management".

6. Switch the order of the variables inside the ROLLUP. That is, use ROLLUP(specialty_description, opioid_drug_flag). How does this change the result?
	
Select psr.specialty_description, SUM(pst.total_claim_count), d.opioid_drug_flag
	FROM drug as d 
	LEFT JOIN prescription as pst 
	USING (drug_name)
	LEFT JOIN prescriber as psr
	USING(npi)
WHERE specialty_description IN ('Pain Management','Interventional Pain Management')
GROUP BY Grouping SETS (ROLLUP(specialty_description,opioid_drug_flag));

-- For me this changed the result of the table as a whole. There are no null values under "specialty description", whereas in the previous example there were some blank spots under specialty description. 
	
7. Finally, change your query to use the CUBE function instead of ROLLUP. How does this impact the output?

	Select psr.specialty_description, SUM(pst.total_claim_count), d.opioid_drug_flag
	FROM drug as d 
	LEFT JOIN prescription as pst 
	USING (drug_name)
	LEFT JOIN prescriber as psr
	USING(npi)
WHERE specialty_description IN ('Pain Management','Interventional Pain Management')
GROUP BY Grouping SETS (CUBE(specialty_description,opioid_drug_flag));

--- I feel that there are now more subtotals after using cube than rollup. For instacne, there are 9 rows now instead of a previously run rollup that resulted in 7 rows. 

8. In this question, your goal is to create a pivot table showing for each of the 4 largest cities in Tennessee (Nashville, Memphis, Knoxville, and Chattanooga), the total claim count for each of six common types of opioids: Hydrocodone, Oxycodone, Oxymorphone, Morphine, Codeine, and Fentanyl. For the purpose of this question, we will put a drug into one of the six listed categories if it has the category name as part of its generic name. For example, we could count both of "ACETAMINOPHEN WITH CODEINE" and "CODEINE SULFATE" as being "CODEINE" for the purposes of this question.

The end result of this question should be a table formatted like this:

city       |codeine|fentanyl|hyrdocodone|morphine|oxycodone|oxymorphone|
-----------|-------|--------|-----------|--------|---------|-----------|
CHATTANOOGA|   1323|    3689|      68315|   12126|    49519|       1317|
KNOXVILLE  |   2744|    4811|      78529|   20946|    84730|       9186|
MEMPHIS    |   4697|    3666|      68036|    4898|    38295|        189|
NASHVILLE  |   2043|    6119|      88669|   13572|    62859|       1261|

Select pcr.nppes_provider_city,
		SUM(pct.total_claim_count),
		d.drug_name
FROM prescription as pct
	LEFT JOIN prescriber as pcr
	USING (npi)
	LEFT JOIN drug AS d
	Using (drug_name)
WHERE pcr.nppes_provider_city IN ('NASHVILLE','MEMPHIS','KNOXVILLE','CHATTANOOGA')
	GROUP BY GROUPING SETS(CUBE(nppes_provider_city,d.drug_name));


	






