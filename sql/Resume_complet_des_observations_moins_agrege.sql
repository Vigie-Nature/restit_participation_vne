select distinct 
	TAB2.Num_observation,
	TAB2.observateur,
	TAB2.etablissement,
	TAB2.zip_etab as code_postal_etab,
	TAB2.type_etablissement,
	TAB2.Niveau_scolaire,
	TAB2.effectifs,
	TAB2.Date_observation,
	TAB2.protocole,
	(case when TAB2.Nombre_individus>0 then TAB2.Espece
		  else null END) as Espece2,
	--TAB2.Espece as Espece,
	TAB2.Nombre_individus as Nombre_individus,
	TAB2.calcul_diversite,
	(case when TAB2.photo='Photo de  : ' then NULL
			  else TAB2.photo END) as Photo,
	TAB2.structurepk,
	TAB2.userpk,
	TAB2.groupepk,
	TAB2.zonepk,
	TAB2.academie,
	TAB2.latitude,
	TAB2.longitude,
	TAB2.zone_educative
		  
	from (
		--2 -> Ce niveau d'aggregation permet d'avoir une ligne par espece avec le nombre d'individus (utile pour gerer les vers de terre)
		select distinct 
		TAB.Num_observation,
		concat(UPPER(TAB.nom), ' ',initcap(TAB.prenom), ' | ', TAB.email) as observateur,
		concat(TAB.nom_etab, ' (', TAB.ville_etab,', ', left(TAB.zip_etab,5), ')') as etablissement,
		TAB.zip_etab,
		TAB.type_etablissement,
		TAB.niveau as Niveau_scolaire,
		TAB.effectifs as effectifs,
		TAB.Date_observation,
		TAB.protocole,
		TAB.Espece as Espece,
		SUM(TAB.Nombre_individus) as Nombre_individus,
		TAB.calcul_diversite,
		concat('Photo de ', TAB.nom_espece, ' : ', TAB.url_photo) as photo,
		TAB.structurepk,
		TAB.userpk,
		TAB.groupepk,
		TAB.zonepk,
		TAB.zone_educative,
		TAB.academie,
		TAB.longitude,
		TAB.latitude

		
		from (
			--1 -> Cette premiere sous-requ?te permet d'avoir la liste des observations, de regrouper les vers adultes et juveniles, de gerer l'ancien protocole inventaire escargots et enfin d'ajouter une abondance =1 pour les plantes
			SELECT
			   observations.observationpk AS Num_observation,
			   users.userpk as userpk,
			   users.nom as nom,
			   users.prenom as prenom,
			   users.email as email,
			   groupes.groupepk,
			   groupes.niveau,
			   groupes.effectifs, 
			   zones.latitude,
			   zones.longitude,
			   zones.zone_educative,
			   dico_structures.structurepk as structurepk,
			   dico_structures.type AS type_etablissement,
			   dico_structures."name" as nom_etab,
			   dico_structures.zipcode as zip_etab,
			   dico_structures.city as ville_etab,
			   dico_academies."name" as academie,
			   observations.date AS Date_observation,
			   dico_protocoles.nom_courant as protocole,
			   (CASE observations_abondances.nom_espece WHEN 'Anecique t?te noire (juvenile)' THEN 'Anecique t?te noire' 
								   					   WHEN 'Anecique t?te rouge (juvenile)' THEN 'Anecique t?te rouge'
								   					   WHEN 'Endoge (juvenile)' THEN 'Endoge'
								   					   WHEN 'Epiges (juvenile)' THEN 'Epige'
								   					   WHEN 'Epige (juvenile)' THEN 'Epige'
								   					   ELSE dico_species.nom_espece END) as Espece,
			   (CASE WHEN observations.protocolefk=5 and observations_abondances.nom_espece isnull THEN 0
			   		 WHEN observations.protocolefk=5 and observations_abondances.nom_espece notnull THEN 1
			   		 when observations_abondances.presence_individu=true then 1
			   		 when observations_abondances.abondance isnull then 0
			   		 else observations_abondances.abondance end) AS Nombre_individus,
			   (case when observations_abondances.abondance>0 then 1
			   		 when observations_abondances.presence_individu=true then 1
			   		 WHEN observations.protocolefk=5 and observations_abondances.nom_espece isnull THEN 0
			   		 WHEN observations.protocolefk=5 and observations_abondances.nom_espece notnull THEN 1
			   		 else 0 END) as calcul_diversite,
			   	observations_abondances.photo_taxon-> '0' ->>'url' AS url_photo,
			   	(case when observations.protocolefk=3 then observations_abondances.nom_espece
			   		  else (select dico_species.nom_espece from dico_species where dico_species.speciepk = cast(observations_abondances.photo_taxon-> '0' ->>'speciepk' as integer)) end) as nom_espece,
			   	zones.zonepk
			
			FROM observations
			LEFT JOIN observations_abondances on observations_abondances.observationfk = observations.observationpk
			left join observations_details_vdt on observations_details_vdt.observationfk = observations.observationpk
			LEFT JOIN observateurs ON observateurs.observateurpk = observations.observateurfk
			LEFT JOIN groupes ON groupes.groupepk = observateurs.groupefk
			LEFT JOIN users ON users.userpk = groupes.userfk
			left join dico_structures on dico_structures.structurepk = groupes.structurefk
			left join dico_protocoles on dico_protocoles.protocolepk = observations.protocolefk
			left join dico_species on dico_species.speciepk = observations_abondances.speciefk 
			left join zones_changes on observations.zonechangefk = zones_changes.zonechangepk
			left join zones on zones.zonepk = zones_changes.zonefk
			left join dico_academies on dico_structures.academiefk = dico_academies.academiepk
			
			
			WHERE
			users.email not in('vne5@yopmail.com')
			--and dico_structures.zipcode in ('74450', '74220', '74230', '74290')
			--and dico_structures.zipcode='91350'
			--and dico_structures.academiefk = 12
			--and observations.observationpk=105508
			--and observations.protocolefk = '14'
			--and dico_structures.villefk ='54982'
			-- and dico_structures.no_uai in('0931217T', '0931196V', '0921610A', '0771600W', '0770930T', '0940138P', '0772296C', '0751152V', '0921178F', '0921541A', '0951785Z', '0951034H', '0920147K', '0920134W', '0950640E', '0911962N', '0922801V')
			-- and left(dico_structures.zipcode, 2) in('95','75','78','91', '92', '93', '77', '94')
			
			order by observations.observationpk
			)TAB
		
		group by 
		TAB.Num_observation,
		TAB.nom,
		TAB.prenom,
		TAB.email,
		TAB.nom_etab, 
		TAB.zip_etab,
		TAB.type_etablissement,
		TAB.ville_etab,  
		TAB.structurepk,
		TAB.niveau,
		TAB.effectifs,
		TAB.Date_observation,
		TAB.protocole,
		TAB.Espece,
		TAB.calcul_diversite,
		TAB.nom_espece,
		TAB.url_photo,
		TAB.userpk,
		TAB.groupepk,
		TAB.zonepk,
		TAB.academie,
		TAB.latitude,
		TAB.longitude,
		TAB.zone_educative
		
		order by TAB.Num_observation
		)TAB2
