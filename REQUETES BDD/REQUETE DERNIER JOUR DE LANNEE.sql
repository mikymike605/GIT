SELECT CAST(CAST (year (debut_date)AS VARCHAR(4)) + '-12-31' AS DATE)
from comm..organne_comp
where year (debut_date) = 
	(
	select annee
	from parameters
	where domaine='annee_comparable'
	)

