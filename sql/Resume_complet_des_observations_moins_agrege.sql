select distinct 
	TAB2.Num_observation as session_id,
	TAB2.observateur,
	TAB2.etablissement,
	TAB2.zip_etab as code_postal_etab,
	TAB2.type_etablissement,
	TAB2.Niveau_scolaire,
	TAB2.effectifs,
	TAB2.Date_observation as session_date,
	TAB2.protocole,
	(case when TAB2.Nombre_individus>0 then TAB2.Espece
		  else null END) as Espece2,
	TAB2.Nombre_individus as Nombre_individus,
	TAB2.calcul_diversite,
	(case when TAB2.photo='Photo de  : ' then NULL
			  else TAB2.photo END) as Photo,
	TAB2.structurepk,
	TAB2.userpk as user_id,
	TAB2.groupepk,
	TAB2.zonepk,
	TAB2.academie,
	TAB2.latitude,
	TAB2.longitude,
	TAB2.zone_educative
		  
	from (
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
