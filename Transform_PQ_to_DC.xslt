<?xml version="1.0" ?>
<!--
	Copyright (c) 2012 The University of Iowa, by Shawn Averkamp, Joanna Lee, & Logal Jewett
	Modifications Copyright (c) 2019 Walden University, by Heather Westerlund
	2019-06: Updated XML to be compliant with ProQuest and Digital Common's updated schemas. Updated structure to function with batch file process. Added discipline and degree crosswalks. Updated embargo settings. Added advisor name formatting rules.

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:str="http://www.metaphoricalweb.org/xmlns/string-utilities"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:util="http://blank">
	
	<xsl:output method="xml" indent="yes" />

	<!-- Transform of ProQuest XML to Digital Commons XML Schema for Electronic Theses and Dissertations (ETDs) -->

	<!-- function to transform title from all caps to title case (stopwords included) -->
	<xsl:function name="str:title-case" as="xs:string">
		<xsl:param name="expr"/>
		<xsl:variable name="tokens" select="tokenize($expr, '(~)|( )')"/>
		<xsl:variable name="titledTokens"
			select="for $token in $tokens return 
			concat(upper-case(substring($token,1,1)),
			lower-case(substring($token,2)))"/>
		<xsl:value-of select="$titledTokens"/>
	</xsl:function>
	
	<xsl:function name="util:strip-tags">
  		<xsl:param name="text"/>
  			<xsl:choose>
   				<xsl:when test="contains($text, '&lt;')">
     				 <xsl:value-of select="concat(substring-before($text, '&lt;'),
       					 util:strip-tags(substring-after($text, '&gt;')))"/>
    			</xsl:when>
    			<xsl:otherwise>
     	 			<xsl:value-of select="$text"/>
    			</xsl:otherwise>
  			</xsl:choose>
	</xsl:function>

	<xsl:template match="/">
		<documents xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:noNamespaceSchemaLocation="http://www.bepress.com/document-import.xsd">

			<xsl:for-each select="root/DISS_submission">
				<document>

					<title>
						<xsl:variable name="title" select="DISS_description/DISS_title"/>

						<xsl:choose>
							<xsl:when test="contains($title,'a')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'e')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'i')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'o')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:when test="contains($title,'u')">
								<xsl:value-of select="normalize-space($title)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="title" select="DISS_description/DISS_title"/>
								<xsl:variable name="hyphentitle" select="replace($title, '-', '-~')"/>
								<xsl:value-of
									select="normalize-space(replace(str:title-case((util:strip-tags($hyphentitle))), '- ', '-'))"
								/>
							</xsl:otherwise>
						</xsl:choose>
					</title>

					<!-- We've used DISS_comp_date as our publication date, which is generally represented as yyyy, but if DISS_accept_date is preferred, this will transform date to ISO 8601 format (yyyy-mm-dd).  -->
					<publication-date>
						<xsl:variable name="datestr">
							<xsl:value-of select="DISS_description/DISS_dates/DISS_comp_date"/>
						</xsl:variable>
						<xsl:value-of select="concat($datestr, '-01-01')"/>
					</publication-date>
					<publication_date_date_format>YYYY</publication_date_date_format>
					
					<!-- Author -->
					<authors>
						<xsl:for-each select="DISS_authorship/DISS_author">
							<author xsi:type="individual">
								<email>
										<xsl:value-of select="DISS_contact[@type='current']/DISS_email"/>
								</email>
								<institution>Your University Name</institution>
								<lname>
									<xsl:value-of select="DISS_name/DISS_surname"/>
								</lname>
								<fname>
									<xsl:value-of select="DISS_name/DISS_fname"/>
								</fname>
								<mname>
									<xsl:value-of select="DISS_name/DISS_middle"/>
								</mname>
								<suffix>
									<xsl:value-of select="DISS_name/DISS_suffix"/>
								</suffix>
								
								
							</author>
						</xsl:for-each>
					</authors>

					<!-- Replace with bepress discipline and reorganize -->
					<disciplines>
						<xsl:for-each select="DISS_description/DISS_categorization/DISS_category/DISS_cat_desc">
							<discipline>
								<xsl:variable name="discstring">
									<xsl:value-of select="."/>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="contains($discstring,'Health education')">
										<xsl:value-of select="replace($discstring, 'Health education','Public Health Education and Promotion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational leadership')">
										<xsl:value-of select="replace($discstring, 'Educational leadership','Educational Administration and Supervision')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational administration')">
										<xsl:value-of select="replace($discstring, 'Educational administration','Educational Administration and Supervision')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Adult education')">
										<xsl:value-of select="replace($discstring, 'Adult education','Adult and Continuing Education Administration;Adult and Continuing Education and Teaching')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Aeronomy')">
										<xsl:value-of select="replace($discstring, 'Aeronomy','Atmospheric Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Aesthetics')">
										<xsl:value-of select="replace($discstring, 'Aesthetics','Esthetics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'African literature')">
										<xsl:value-of select="replace($discstring, 'African literature','African Languages and Societies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'African studies')">
										<xsl:value-of select="replace($discstring, 'African studies','African Languages and Societies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Aging')">
										<xsl:value-of select="replace($discstring, 'Aging','Family, Life Course, and Society')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Agriculture economics')">
										<xsl:value-of select="replace($discstring, 'Agriculture economics','Agriculture;Agricultural Economics;Agricultural and Resource Economics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Agriculture education')">
										<xsl:value-of select="replace($discstring, 'Agriculture education','Agriculture;Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Agriculture engineering')">
										<xsl:value-of select="replace($discstring, 'Agriculture engineering','Agriculture;Bioresource and Agricultural Engineering')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Agronomy')">
										<xsl:value-of select="replace($discstring, 'Agronomy','Agriculture;Agricultural Science;Agronomy and Crop Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Alternative dispute resolution')">
										<xsl:value-of select="replace($discstring, 'Alternative dispute resolution','Dispute Resolution and Administration')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Alternative energy')">
										<xsl:value-of select="replace($discstring, 'Alternative energy','Oil, Gas, and Energy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Alternative medicine')">
										<xsl:value-of select="replace($discstring, 'Alternative medicine','Alternative and Complementary Medicine')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'American history')">
										<xsl:value-of select="replace($discstring, 'American history','United States History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'American literature')">
										<xsl:value-of select="replace($discstring, 'American literature','American Literature;Literature in English, North America')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Ancient history')">
										<xsl:value-of select="replace($discstring, 'Ancient history','Ancient History, Greek and Roman through Late Antiquity')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Ancient languages')">
										<xsl:value-of select="replace($discstring, 'Ancient languages','Indo-European Linguistics and Philology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Animal behavior')">
										<xsl:value-of select="replace($discstring, 'Animal behavior','Behavior and Ethology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Animal sciences')">
										<xsl:value-of select="replace($discstring, 'Animal sciences','Agriculture;Animal Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Archaeology')">
										<xsl:value-of select="replace($discstring, 'Archaeology','History of Art, Architecture, and Archaeology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Area planning and development')">
										<xsl:value-of select="replace($discstring, 'Area planning and development','Urban, Community and Regional Planning')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Art criticism')">
										<xsl:value-of select="replace($discstring, 'Art criticism','Theory and Criticism')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Art history')">
										<xsl:value-of select="replace($discstring, 'Art history','History of Art, Architecture, and Archaeology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Artificial intelligence')">
										<xsl:value-of select="replace($discstring, 'Artificial intelligence','Artificial Intelligence and Robotics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Asian literature')">
										<xsl:value-of select="replace($discstring, 'Asian literature','Arts and Humanities')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Astronomy')">
										<xsl:value-of select="replace($discstring, 'Astronomy','Astrophysics and Astronomy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Astronomy Astrophysics')">
										<xsl:value-of select="replace($discstring, 'Astronomy Astrophysics','Astrophysics and Astronomy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Astrophysics')">
										<xsl:value-of select="replace($discstring, 'Astrophysics','Astrophysics and Astronomy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Atmospheric chemistry')">
										<xsl:value-of select="replace($discstring, 'Atmospheric chemistry','Atmospheric Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Atomic physics')">
										<xsl:value-of select="replace($discstring, 'Atomic physics','Atomic, Molecular and Optical Physics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Audiology')">
										<xsl:value-of select="replace($discstring, 'Audiology','Speech Pathology and Audiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Automotive engineering')">
										<xsl:value-of select="replace($discstring, 'Automotive engineering','Mechanical Engineering')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Baltic studies')">
										<xsl:value-of select="replace($discstring, 'Baltic studies','European Languages and Societies;Eastern European Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Banking')">
										<xsl:value-of select="replace($discstring, 'Banking','Finance and Financial Management')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Behavioral psychology')">
										<xsl:value-of select="replace($discstring, 'Behavioral psychology','Social and Behavioral Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Behavioral sciences')">
										<xsl:value-of select="replace($discstring, 'Behavioral sciences','Social and Behavioral Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Bilingual')">
										<xsl:value-of select="replace($discstring, 'Bilingual','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Bilingual education')">
										<xsl:value-of select="replace($discstring, 'Bilingual education','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Biographies')">
										<xsl:value-of select="replace($discstring, 'Biographies','Biography')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Biological oceanography')">
										<xsl:value-of select="replace($discstring, 'Biological oceanography','Oceanography')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Biomedical engineering')">
										<xsl:value-of select="replace($discstring, 'Biomedical engineering','Biomedical')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Biosystems')">
										<xsl:value-of select="replace($discstring, 'Biosystems','Systems Biology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Black history')">
										<xsl:value-of select="replace($discstring, 'Black history','African American Studies;United States History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Black studies')">
										<xsl:value-of select="replace($discstring, 'Black studies','African American Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'British and Irish literature')">
										<xsl:value-of select="replace($discstring, 'British and Irish literature','Literature in English, British Isles')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Business administration')">
										<xsl:value-of select="replace($discstring, 'Business administration','Business')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Business education')">
										<xsl:value-of select="replace($discstring, 'Business education','Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Canadian history')">
										<xsl:value-of select="replace($discstring, 'Canadian history','Other History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Canadian literature')">
										<xsl:value-of select="replace($discstring, 'Canadian literature','Literature in English, North America')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Canadian studies')">
										<xsl:value-of select="replace($discstring, 'Canadian studies','Other International and Area Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Canon law')">
										<xsl:value-of select="replace($discstring, 'Canon law','Religion Law')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Caribbean literature')">
										<xsl:value-of select="replace($discstring, 'Caribbean literature','Latin American Literature')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Caribbean studies')">
										<xsl:value-of select="replace($discstring, 'Caribbean studies','Latin American Languages and Societies;Latin American Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Cellular biology')">
										<xsl:value-of select="replace($discstring, 'Cellular biology','Cell Biology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Chemical oceanography')">
										<xsl:value-of select="replace($discstring, 'Chemical oceanography','Oceanography')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Cinematography')">
										<xsl:value-of select="replace($discstring, 'Cinematography','Film and Media Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Classical literature')">
										<xsl:value-of select="replace($discstring, 'Classical literature','Classical Literature and Philology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Classical studies')">
										<xsl:value-of select="replace($discstring, 'Classical studies','Classics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Clerical studies')">
										<xsl:value-of select="replace($discstring, 'Clerical studies','Other Religion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Climate change')">
										<xsl:value-of select="replace($discstring, 'Climate change','Climate;Environmental Indicators and Impact Assessment')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Community college education')">
										<xsl:value-of select="replace($discstring, 'Community college education','Community College Leadership;Community College Education Administration')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Comparative religion')">
										<xsl:value-of select="replace($discstring, 'Comparative religion','Comparative Methodologies and Theories')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Computer science')">
										<xsl:value-of select="replace($discstring, 'Computer science','Computer Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Conservation biology')">
										<xsl:value-of select="replace($discstring, 'Conservation biology','Biodiversity;Natural Resources and Conservation;Natural Resources Management and Policy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Continental dynamics')">
										<xsl:value-of select="replace($discstring, 'Continental dynamics','Tectonics and Structure')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Continuing education')">
										<xsl:value-of select="replace($discstring, 'Continuing education','Adult and Continuing Education Administration;Adult and Continuing Education and Teaching')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Criminology')">
										<xsl:value-of select="replace($discstring, 'Criminology','Criminology and Criminal Justice;Criminology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Cultural anthropology')">
										<xsl:value-of select="replace($discstring, 'Cultural anthropology','Social and Cultural Anthropology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Cultural resource management')">
										<xsl:value-of select="replace($discstring, 'Cultural resource management','Cultural Resource Management and Policy Analysis')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Cultural resources management')">
										<xsl:value-of select="replace($discstring, 'Cultural resources management','Cultural Resource Management and Policy Analysis')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Curriculum development')">
										<xsl:value-of select="replace($discstring, 'Curriculum development','Curriculum and Instruction')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Demography')">
										<xsl:value-of select="replace($discstring, 'Demography','Demography, Population, and Ecology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Design')">
										<xsl:value-of select="replace($discstring, 'Design','Art and Design;Graphic Design')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Divinity')">
										<xsl:value-of select="replace($discstring, 'Divinity','Other Religion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Early childhood education')">
										<xsl:value-of select="replace($discstring, 'Early childhood education','Pre-Elementary, Early Childhood, Kindergarten Teacher Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'East European studies')">
										<xsl:value-of select="replace($discstring, 'East European studies','European Languages and Societies;Eastern European Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Ecology')">
										<xsl:value-of select="replace($discstring, 'Ecology','Ecology and Evolutionary Biology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Economics, Commerce-Business')">
										<xsl:value-of select="replace($discstring, 'Economics, Commerce-Business','Economics;Other Economics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Economics, Labor')">
										<xsl:value-of select="replace($discstring, 'Economics, Labor','Labor Economics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Education finance')">
										<xsl:value-of select="replace($discstring, 'Education finance','Educational Administration and Supervision')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Education history')">
										<xsl:value-of select="replace($discstring, 'Education history','Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Education philosophy')">
										<xsl:value-of select="replace($discstring, 'Education philosophy','Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational administration')">
										<xsl:value-of select="replace($discstring, 'Educational administration','Educational Administration and Supervision')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational evaluation')">
										<xsl:value-of select="replace($discstring, 'Educational evaluation','Educational Assessment, Evaluation, and Research')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational leadership')">
										<xsl:value-of select="replace($discstring, 'Educational leadership','Educational Administration and Supervision')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational sociology')">
										<xsl:value-of select="replace($discstring, 'Educational sociology','Education; Sociology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational technology')">
										<xsl:value-of select="replace($discstring, 'Educational technology','Instructional Media Design')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Educational tests &amp; measurements')">
										<xsl:value-of select="replace($discstring, 'Educational tests &amp; measurements','Educational Assessment, Evaluation, and Research')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Electrical engineering')">
										<xsl:value-of select="replace($discstring, 'Electrical engineering','Electrical and Electronics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Electromagnetics')">
										<xsl:value-of select="replace($discstring, 'Electromagnetics','Electromagnetics and photonics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Elementary education')">
										<xsl:value-of select="replace($discstring, 'Elementary education','Elementary and Middle and Secondary Education Administration;Elementary Education and Teaching')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Endocrinology')">
										<xsl:value-of select="replace($discstring, 'Endocrinology','Endocrinology;Endocrinology, Diabetes, and Metabolism')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Energy')">
										<xsl:value-of select="replace($discstring, 'Energy','Oil, Gas, and Energy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'English as a second language')">
										<xsl:value-of select="replace($discstring, 'English as a second language','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Entrepreneurship')">
										<xsl:value-of select="replace($discstring, 'Entrepreneurship','Entrepreneurial and Small Business Operations')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental economics')">
										<xsl:value-of select="replace($discstring, 'Environmental economics','Natural Resource Economics;Economics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental education')">
										<xsl:value-of select="replace($discstring, 'Environmental education','Education;Environmental Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental geology')">
										<xsl:value-of select="replace($discstring, 'Environmental geology','Geology;Environmental Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental health')">
										<xsl:value-of select="replace($discstring, 'Environmental health','Environmental Health and Protection')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental justice')">
										<xsl:value-of select="replace($discstring, 'Environmental justice','Environmental Policy;Environmental Sciences;Environmental Law')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental management')">
										<xsl:value-of select="replace($discstring, 'Environmental management','Natural Resources Management and Policy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental philosophy')">
										<xsl:value-of select="replace($discstring, 'Environmental philosophy','Environmental Sciences;Philosophy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental science')">
										<xsl:value-of select="replace($discstring, 'Environmental science','Environmental Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Environmental studies')">
										<xsl:value-of select="replace($discstring, 'Environmental studies','Environmental Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Ethics')">
										<xsl:value-of select="replace($discstring, 'Ethics','Ethics and Political Philosophy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'European studies')">
										<xsl:value-of select="replace($discstring, 'European studies','European Languages and Societies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Evolution &amp; development')">
										<xsl:value-of select="replace($discstring, 'Evolution &amp; development','Evolution')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Experimental psychology')">
										<xsl:value-of select="replace($discstring, 'Experimental psychology','Psychology;Other Psychology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Film studies')">
										<xsl:value-of select="replace($discstring, 'Film studies','Film and Media Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Finance')">
										<xsl:value-of select="replace($discstring, 'Finance','Finance and Financial Management')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Fisheries and aquatic sciences')">
										<xsl:value-of select="replace($discstring, 'Fisheries and aquatic sciences','Agriculture;Animal Sciences;Aquaculture and Fisheries')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Foreign language education')">
										<xsl:value-of select="replace($discstring, 'Foreign language education','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Foreign language instruction')">
										<xsl:value-of select="replace($discstring, 'Foreign language instruction','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Forensic anthropology')">
										<xsl:value-of select="replace($discstring, 'Forensic anthropology','Biological and Physical Anthropology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Forestry')">
										<xsl:value-of select="replace($discstring, 'Forestry','Forest Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'French Canadian culture')">
										<xsl:value-of select="replace($discstring, 'French Canadian culture','Other Languages, Societies, and Cultures')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'French Canadian literature')">
										<xsl:value-of select="replace($discstring, 'French Canadian literature','French and Francophone Literature;Other French and Francophone Literature')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Gender studies')">
										<xsl:value-of select="replace($discstring, 'Gender studies','Feminist, Gender, and Sexuality Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Geobiology')">
										<xsl:value-of select="replace($discstring, 'Geobiology','Systems Biology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Geographic information science and geodesy')">
										<xsl:value-of select="replace($discstring, 'Geographic information science and geodesy','Geographic Information Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Geological engineering')">
										<xsl:value-of select="replace($discstring, 'Geological engineering','Geotechnical Engineering')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Geophysical engineering')">
										<xsl:value-of select="replace($discstring, 'Geophysical engineering','Geotechnical Engineering')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Geophysics')">
										<xsl:value-of select="replace($discstring, 'Geophysics','Geophysics and Seismology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Geotechnology')">
										<xsl:value-of select="replace($discstring, 'Geotechnology','Geotechnical Engineering')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Germanic literature')">
										<xsl:value-of select="replace($discstring, 'Germanic literature','German Literature')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Gerontology')">
										<xsl:value-of select="replace($discstring, 'Gerontology','Family, Life Course, and Society')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'GLBT studies')">
										<xsl:value-of select="replace($discstring, 'GLBT studies','Lesbian, Gay, Bisexual, and Transgender Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Health care management')">
										<xsl:value-of select="replace($discstring, 'Health care management','Health and Medical Administration')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Health education')">
										<xsl:value-of select="replace($discstring, 'Health education','Public Health Education and Promotion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Health sciences')">
										<xsl:value-of select="replace($discstring, 'Health sciences','Medicine and Health Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Health Sciences, Education')">
										<xsl:value-of select="replace($discstring, 'Health Sciences, Education','Public Health Education and Promotion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'High temperature physics')">
										<xsl:value-of select="replace($discstring, 'High temperature physics','Physics;Other Physics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Higher education')">
										<xsl:value-of select="replace($discstring, 'Higher education','Higher Education Administration;Higher Education and Teaching')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Hispanic American studies')">
										<xsl:value-of select="replace($discstring, 'Hispanic American studies','Other Race, Ethnicity and post-Colonial Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Histology')">
										<xsl:value-of select="replace($discstring, 'Histology','Cell Anatomy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'History of education')">
										<xsl:value-of select="replace($discstring, 'History of education','Other History;Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'History of Oceania')">
										<xsl:value-of select="replace($discstring, 'History of Oceania','Other History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'History of science')">
										<xsl:value-of select="replace($discstring, 'History of science','History of Science, Technology, and Medicine')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Holocaust studies')">
										<xsl:value-of select="replace($discstring, 'Holocaust studies','Jewish Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Home economics education')">
										<xsl:value-of select="replace($discstring, 'Home economics education','Home Economics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Horticulture')">
										<xsl:value-of select="replace($discstring, 'Horticulture','Agriculture;Agricultural Science;Horticulture')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Hydrologic sciences')">
										<xsl:value-of select="replace($discstring, 'Hydrologic sciences','Hydrology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Icelandic &amp; Scandinavian literature')">
										<xsl:value-of select="replace($discstring, 'Icelandic &amp; Scandinavian literature','Other Languages, Societies, and Cultures')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Immunology')">
										<xsl:value-of select="replace($discstring, 'Immunology','Immunology and Infectious Disease;Allergy and Immunology;Medical Immunology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Individual &amp; family studies')">
										<xsl:value-of select="replace($discstring, 'Individual &amp; family studies','Family, Life Course, and Society')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Industrial arts education')">
										<xsl:value-of select="replace($discstring, 'Industrial arts education','Industrial Engineering;Industrial Technology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Information science')">
										<xsl:value-of select="replace($discstring, 'Information science','Library and Information Science')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Information technology')">
										<xsl:value-of select="replace($discstring, 'Information technology','Databases and Information Systems')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Instructional design')">
										<xsl:value-of select="replace($discstring, 'Instructional design','Curriculum and Instruction')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Islamic culture')">
										<xsl:value-of select="replace($discstring, 'Islamic culture','Near Eastern Languages and Societies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Journalism')">
										<xsl:value-of select="replace($discstring, 'Journalism','Journalism Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Judaic studies')">
										<xsl:value-of select="replace($discstring, 'Judaic studies','Jewish Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Labor relations')">
										<xsl:value-of select="replace($discstring, 'Labor relations','Labor Economics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Land use planning')">
										<xsl:value-of select="replace($discstring, 'Land use planning','Urban, Community and Regional Planning')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Language')">
										<xsl:value-of select="replace($discstring, 'Language','Other Languages, Societies, and Cultures')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Language arts')">
										<xsl:value-of select="replace($discstring, 'Language arts','Liberal Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Latin American studies')">
										<xsl:value-of select="replace($discstring, 'Latin American studies','Latin American Languages and Societies;Latin American Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Library science')">
										<xsl:value-of select="replace($discstring, 'Library science','Library and Information Science')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Limnology')">
										<xsl:value-of select="replace($discstring, 'Limnology','Fresh Water Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Literacy Reading Instruction')">
										<xsl:value-of select="replace($discstring, 'Literacy Reading Instruction','Reading and Language; Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Literacy; Reading instruction')">
										<xsl:value-of select="replace($discstring, 'Literacy; Reading instruction','Reading and Language; Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Literature')">
										<xsl:value-of select="replace($discstring, 'Literature','English Language and Literature')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Literature of Oceania')">
										<xsl:value-of select="replace($discstring, 'Literature of Oceania','Other Languages, Societies, and Cultures')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Logic')">
										<xsl:value-of select="replace($discstring, 'Logic','Logic and foundations of mathematics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Low temperature physics')">
										<xsl:value-of select="replace($discstring, 'Low temperature physics','Physics;Other Physics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Macroecology')">
										<xsl:value-of select="replace($discstring, 'Macroecology','Ecology and Evolutionary Biology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Management')">
										<xsl:value-of select="replace($discstring, 'Management','Business Administration, Management, and Operations;Management Sciences and Quantitative Methods')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Marine geology')">
										<xsl:value-of select="replace($discstring, 'Marine geology','Geology;Oceanography')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Marketing')">
										<xsl:value-of select="replace($discstring, 'Marketing','Advertising and Promotion Management;Marketing')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Materials Science')">
										<xsl:value-of select="replace($discstring, 'Materials Science','Mechanics of Materials')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Mathematics education')">
										<xsl:value-of select="replace($discstring, 'Mathematics education','Science and Mathematics Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Mechanics')">
										<xsl:value-of select="replace($discstring, 'Mechanics','Engineering Mechanics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Medical ethics')">
										<xsl:value-of select="replace($discstring, 'Medical ethics','Bioethics and Medical Ethics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Medical imaging')">
										<xsl:value-of select="replace($discstring, 'Medical imaging','Radiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Medical imaging and radiology')">
										<xsl:value-of select="replace($discstring, 'Medical imaging and radiology','Radiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Medicine')">
										<xsl:value-of select="replace($discstring, 'Medicine','Medicine and Health Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Medieval Literature')">
										<xsl:value-of select="replace($discstring, 'Medieval Literature','Medieval Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Mental health')">
										<xsl:value-of select="replace($discstring, 'Mental health','Psychiatric and Mental Health')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Middle Eastern history')">
										<xsl:value-of select="replace($discstring, 'Middle Eastern history','Islamic World and  Near East History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Middle Eastern literature')">
										<xsl:value-of select="replace($discstring, 'Middle Eastern literature','Near Eastern Languages and Societies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Middle Eastern studies')">
										<xsl:value-of select="replace($discstring, 'Middle Eastern studies','Near Eastern Languages and Societies;Other International and Area Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Middle school education')">
										<xsl:value-of select="replace($discstring, 'Middle school education','Elementary and Middle and Secondary Education Administration;Junior High, Intermediate, Middle School Education and Teaching')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Mineralogy')">
										<xsl:value-of select="replace($discstring, 'Mineralogy','Geology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Modern history')">
										<xsl:value-of select="replace($discstring, 'Modern history','History;Other History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Modern language')">
										<xsl:value-of select="replace($discstring, 'Modern language','Modern Languages')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Molecular chemistry')">
										<xsl:value-of select="replace($discstring, 'Molecular chemistry','Chemistry')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Molecular physics')">
										<xsl:value-of select="replace($discstring, 'Molecular physics','Atomic, Molecular and Optical Physics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Multicultural Education')">
										<xsl:value-of select="replace($discstring, 'Multicultural Education','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Multilingual')">
										<xsl:value-of select="replace($discstring, 'Multilingual','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Multilingual education')">
										<xsl:value-of select="replace($discstring, 'Multilingual education','Bilingual, Multilingual, and Multicultural Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Multimedia')">
										<xsl:value-of select="replace($discstring, 'Multimedia','Interactive Arts')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Multimedia Communications')">
										<xsl:value-of select="replace($discstring, 'Multimedia Communications','Interactive Arts; Communication')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Museum studies')">
										<xsl:value-of select="replace($discstring, 'Museum studies','Other History of Art, Architecture, and Archaeology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Music education')">
										<xsl:value-of select="replace($discstring, 'Music education','Music Pedagogy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Nanoscience')">
										<xsl:value-of select="replace($discstring, 'Nanoscience','Nanoscience and Nanotechnology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Nanotechnology')">
										<xsl:value-of select="replace($discstring, 'Nanotechnology','Nanoscience and Nanotechnology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Natural resource management')">
										<xsl:value-of select="replace($discstring, 'Natural resource management','Natural Resources Management and Policy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Naval engineering')">
										<xsl:value-of select="replace($discstring, 'Naval engineering','Industrial Engineering')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Near Eastern studies')">
										<xsl:value-of select="replace($discstring, 'Near Eastern studies','Near Eastern Languages and Societies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Neuroscience')">
										<xsl:value-of select="replace($discstring, 'Neuroscience','Neuroscience and Neurobiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Neurosciences')">
										<xsl:value-of select="replace($discstring, 'Neurosciences','Neuroscience and Neurobiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'North African studies')">
										<xsl:value-of select="replace($discstring, 'North African studies','Near Eastern Languages and Societies;African Languages and Societies;African Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Nuclear chemistry')">
										<xsl:value-of select="replace($discstring, 'Nuclear chemistry','Chemistry;Other Chemistry')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Nuclear physics')">
										<xsl:value-of select="replace($discstring, 'Nuclear physics','Nuclear')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Nutrition')">
										<xsl:value-of select="replace($discstring, 'Nutrition','Nutrition;Human and Clinical Nutrition')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Obstetrics Gynecology')">
										<xsl:value-of select="replace($discstring, 'Obstetrics Gynecology','Obstetrics and Gynecology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Occupational health')">
										<xsl:value-of select="replace($discstring, 'Occupational health','Occupational Health and Industrial Hygiene')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Occupational psychology')">
										<xsl:value-of select="replace($discstring, 'Occupational psychology','Vocational Rehabilitation Counseling')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Operations research')">
										<xsl:value-of select="replace($discstring, 'Operations research','Operational Research')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Organization theory')">
										<xsl:value-of select="replace($discstring, 'Organization theory','Organizational Behavior and Theory')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Organizational behavior')">
										<xsl:value-of select="replace($discstring, 'Organizational behavior','Organizational Behavior and Theory')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Osteopathic medicine')">
										<xsl:value-of select="replace($discstring, 'Osteopathic medicine','Osteopathic Medicine and Osteopathy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Pacific Rim studies')">
										<xsl:value-of select="replace($discstring, 'Pacific Rim studies','Other International and Area Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Packaging')">
										<xsl:value-of select="replace($discstring, 'Packaging','Product Design')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Paleoclimate science')">
										<xsl:value-of select="replace($discstring, 'Paleoclimate science','Climate;Paleontology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Paleoecology')">
										<xsl:value-of select="replace($discstring, 'Paleoecology','Ecology and Evolutionary Biology;Paleontology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Particle physics')">
										<xsl:value-of select="replace($discstring, 'Particle physics','Elementary Particles and Fields and String Theory')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Pastoral counseling')">
										<xsl:value-of select="replace($discstring, 'Pastoral counseling','Other Religion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Patent law')">
										<xsl:value-of select="replace($discstring, 'Patent law','Intellectual Property Law')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Peace studies')">
										<xsl:value-of select="replace($discstring, 'Peace studies','Peace and Conflict Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Pedagogy')">
										<xsl:value-of select="replace($discstring, 'Pedagogy','Educational Methods;Curriculum and Instruction')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Performing arts')">
										<xsl:value-of select="replace($discstring, 'Performing arts','Theatre and Performance Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Performing arts education')">
										<xsl:value-of select="replace($discstring, 'Performing arts education','Theatre and Performance Studies;Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Personality psychology')">
										<xsl:value-of select="replace($discstring, 'Personality psychology','Personality and Social Contexts')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Petroleum geology')">
										<xsl:value-of select="replace($discstring, 'Petroleum geology','Oil, Gas, and Energy;Geology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Petrology')">
										<xsl:value-of select="replace($discstring, 'Petrology','Geology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Pharmaceutical sciences')">
										<xsl:value-of select="replace($discstring, 'Pharmaceutical sciences','Pharmacy and Pharmaceutical Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Pharmacy sciences')">
										<xsl:value-of select="replace($discstring, 'Pharmacy sciences','Pharmacy and Pharmaceutical Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Philosophy of education')">
										<xsl:value-of select="replace($discstring, 'Philosophy of education','Social and Philosophical Foundations of Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Philosophy of Religion')">
										<xsl:value-of select="replace($discstring, 'Philosophy of Religion','Religious Thought, Theology and Philosophy of Religion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Physical anthropology')">
										<xsl:value-of select="replace($discstring, 'Physical anthropology','Biological and Physical Anthropology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Physical education')">
										<xsl:value-of select="replace($discstring, 'Physical education','Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Physical geography')">
										<xsl:value-of select="replace($discstring, 'Physical geography','Physical and Environmental Geography')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Physical oceanography')">
										<xsl:value-of select="replace($discstring, 'Physical oceanography','Oceanography')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Physiological psychology')">
										<xsl:value-of select="replace($discstring, 'Physiological psychology','Biological Psychology;Behavior and Behavior Mechanisms')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Planetology')">
										<xsl:value-of select="replace($discstring, 'Planetology','Astrophysics and Astronomy;Behavior and Behavior Mechanisms;Psychology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Plant biology')">
										<xsl:value-of select="replace($discstring, 'Plant biology','Agriculture;Agricultural Science;Plant Biology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Plant pathology')">
										<xsl:value-of select="replace($discstring, 'Plant pathology','Agriculture;Agricultural Science;Plant Pathology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Plant sciences')">
										<xsl:value-of select="replace($discstring, 'Plant sciences','Agriculture;Plant Sciences;Agricultural Science')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Plasma physics')">
										<xsl:value-of select="replace($discstring, 'Plasma physics','Plasma and Beam Physics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Plastics')">
										<xsl:value-of select="replace($discstring, 'Plastics','Polymer and Organic Materials')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Plate tectonics')">
										<xsl:value-of select="replace($discstring, 'Plate tectonics','Tectonics and Structure')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Political studies')">
										<xsl:value-of select="replace($discstring, 'Political studies','Political Science')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Psychobiology')">
										<xsl:value-of select="replace($discstring, 'Psychobiology','Behavioral Neurobiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Public health')">
										<xsl:value-of select="replace($discstring, 'Public health','Public Health Education and Promotion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Public health education')">
										<xsl:value-of select="replace($discstring, 'Public health education','Public Health Education and Promotion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Public health occupations education')">
										<xsl:value-of select="replace($discstring, 'Public health occupations education','Medical Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Quantitative pscyhology')">
										<xsl:value-of select="replace($discstring, 'Quantitative pscyhology','Quantitative Psychology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Quantitative psychology and psychometrics')">
										<xsl:value-of select="replace($discstring, 'Quantitative psychology and psychometrics','Quantitative Psychology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Range management')">
										<xsl:value-of select="replace($discstring, 'Range management','Natural Resources Management and Policy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Reading instruction')">
										<xsl:value-of select="replace($discstring, 'Reading instruction','Reading and Language;Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Recreation and tourism')">
										<xsl:value-of select="replace($discstring, 'Recreation and tourism','Recreation, Parks and Tourism Administration;Tourism')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Regional studies')">
										<xsl:value-of select="replace($discstring, 'Regional studies','Other International and Area Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Religious education')">
										<xsl:value-of select="replace($discstring, 'Religious education','Religion;Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Religious history')">
										<xsl:value-of select="replace($discstring, 'Religious history','History of Religion;Religion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Romance literature')">
										<xsl:value-of select="replace($discstring, 'Romance literature','Other Languages, Societies, and Cultures')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Russian history')">
										<xsl:value-of select="replace($discstring, 'Russian history','European History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Scandinavian studies')">
										<xsl:value-of select="replace($discstring, 'Scandinavian studies','European Languages and Societies;Scandinavian Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'School administration')">
										<xsl:value-of select="replace($discstring, 'School administration','Elementary and Middle and Secondary Education Administration')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'School counseling')">
										<xsl:value-of select="replace($discstring, 'School counseling','Educational Psychology;Student Counseling and Personnel Services;School Psychology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Science education')">
										<xsl:value-of select="replace($discstring, 'Science education','Science and Mathematics Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Secondary education')">
										<xsl:value-of select="replace($discstring, 'Secondary education','Elementary and Middle and Secondary Education Administration;Secondary Education and Teaching')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Sedimentary geology')">
										<xsl:value-of select="replace($discstring, 'Sedimentary geology','Sedimentology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Slavic literature')">
										<xsl:value-of select="replace($discstring, 'Slavic literature','Other Languages, Societies, and Cultures')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Slavic studies')">
										<xsl:value-of select="replace($discstring, 'Slavic studies','European Languages and Societies;Slavic Languages and Societies;Eastern European Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Social research')">
										<xsl:value-of select="replace($discstring, 'Social research','Quantitative, Qualitative, Comparative, and Historical Methodologies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Social sciences education')">
										<xsl:value-of select="replace($discstring, 'Social sciences education','Liberal Studies;Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Social structure')">
										<xsl:value-of select="replace($discstring, 'Social structure','Sociology;Other Sociology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Sociolinguistics')">
										<xsl:value-of select="replace($discstring, 'Sociolinguistics','Anthropological Linguistics and Sociolinguistics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Sociology of education')">
										<xsl:value-of select="replace($discstring, 'Sociology of education','Social and Philosophical Foundations of Education;Educational Sociology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Soil sciences')">
										<xsl:value-of select="replace($discstring, 'Soil sciences','Soil Science')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'South African studies')">
										<xsl:value-of select="replace($discstring, 'South African studies','African Languages and Societies;African Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'South Asian studies')">
										<xsl:value-of select="replace($discstring, 'South Asian studies','South and Southeast Asian Languages and Societies;Asian Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Special education')">
										<xsl:value-of select="replace($discstring, 'Special education','Special Education Administration;Special Education and Teaching')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Speech Communication')">
										<xsl:value-of select="replace($discstring, 'Speech Communication','Speech and Hearing Science;Speech Pathology and Audiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Speech therapy')">
										<xsl:value-of select="replace($discstring, 'Speech therapy','Speech and Hearing Science;Speech Pathology and Audiology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Spirituality')">
										<xsl:value-of select="replace($discstring, 'Spirituality','Religion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Statistics')">
										<xsl:value-of select="replace($discstring, 'Statistics','Statistics and Probability')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Sub Saharan Africa studies')">
										<xsl:value-of select="replace($discstring, 'Sub Saharan Africa studies','African Languages and Societies;African Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'System science')">
										<xsl:value-of select="replace($discstring, 'System science','Systems Engineering')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Systematic biology')">
										<xsl:value-of select="replace($discstring, 'Systematic biology','Systems Biology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Teacher education')">
										<xsl:value-of select="replace($discstring, 'Teacher education','Teacher Education and Professional Development')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Technical communication')">
										<xsl:value-of select="replace($discstring, 'Technical communication','Other Communication')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Textile research')">
										<xsl:value-of select="replace($discstring, 'Textile research','Art and Materials Conservation')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Theater')">
										<xsl:value-of select="replace($discstring, 'Theater','Theatre and Performance Studies')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Theater history')">
										<xsl:value-of select="replace($discstring, 'Theater history','Theatre History')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Theology')">
										<xsl:value-of select="replace($discstring, 'Theology','Religious Thought, Theology and Philosophy of Religion')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Theoretical mathematics')">
										<xsl:value-of select="replace($discstring, 'Theoretical mathematics','Mathematics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Theoretical physics')">
										<xsl:value-of select="replace($discstring, 'Theoretical physics','Other Physics')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Transportation planning')">
										<xsl:value-of select="replace($discstring, 'Transportation planning','Transportation')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Urban forestry')">
										<xsl:value-of select="replace($discstring, 'Urban forestry','Other Forestry and Forest Sciences')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Urban planning')">
										<xsl:value-of select="replace($discstring, 'Urban planning','Urban Studies and Planning')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Vocational education')">
										<xsl:value-of select="replace($discstring, 'Vocational education','Other Education')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Water resources management')">
										<xsl:value-of select="replace($discstring, 'Water resources management','Water Resource Management')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Web studies')">
										<xsl:value-of select="replace($discstring, 'Web studies','Communication Technology and New Media')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Wildlife conservation')">
										<xsl:value-of select="replace($discstring, 'Wildlife conservation','Natural Resources and Conservation')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Wildlife management')">
										<xsl:value-of select="replace($discstring, 'Wildlife management','Natural Resources Management and Policy')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'Wood sciences')">
										<xsl:value-of select="replace($discstring, 'Wood sciences','Wood Science and Pulp, Paper Technology')"/>
									</xsl:when>
									<xsl:when test="contains($discstring,'World history')">
										<xsl:value-of select="replace($discstring, 'World history','History')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$discstring"/>
									</xsl:otherwise>
								</xsl:choose>
							</discipline>
						</xsl:for-each>
					</disciplines>

					<!-- Outputs each keyword into its own keyword element , splitting on both semicolon and comma-->
					<keywords>
						<xsl:for-each select="DISS_description/DISS_categorization/DISS_keyword">
							<xsl:variable name="keywordstring">
								<xsl:value-of select="translate(., ';', ',')"/>
							</xsl:variable>
							<xsl:variable name="tokenkeyword"
								select="tokenize($keywordstring, ',\s+')"/>
							<xsl:for-each select="$tokenkeyword">
								<keyword>
									<xsl:value-of select="."/>
								</keyword>
							</xsl:for-each>
						</xsl:for-each>
					</keywords>

					<!-- Abstract  - replaces ProQuest formatting characters to bepress formatting -->
					<abstract>
						<xsl:for-each select="DISS_content/DISS_abstract">
							<xsl:for-each select="DISS_para">
								<xsl:variable name="abstract">
									<xsl:value-of select="."/>
								</xsl:variable>
								<xsl:if test="$abstract!='Abstract'">
									<p>
										<xsl:value-of
											select="concat(normalize-space(replace(
											replace(
											replace(
											replace(
											replace(
											replace(
											replace(
											replace(.,'&lt;bold&gt;','&lt;strong&gt;'),
											'&lt;/bold&gt;','&lt;/strong&gt;'),
											'&lt;italic&gt;','&lt;em&gt;'),
											'&lt;/italic&gt;','&lt;/em&gt;'),
											'&lt;super&gt;','&lt;sup&gt;'),
											'&lt;/super&gt;','&lt;/sup&gt;'),
											'&lt;underline&gt;',' '),
											'&lt;/underline&gt;',' ')),' ')"
										/>
									</p>
								</xsl:if>
							</xsl:for-each>
						</xsl:for-each>
					</abstract>

					<fulltext-url>
						<xsl:variable name="accept">
							<xsl:if test="DISS_repository/DISS_acceptance">
								<xsl:value-of select="DISS_repository/DISS_acceptance"/>
							</xsl:if>
							<xsl:if test="not(DISS_repository/DISS_acceptance)">
								<xsl:value-of select="1"/>
							</xsl:if>
							<!-- added as a temporary workaround to transform a value of 0 to 1 -->
							<xsl:if test="DISS_repository/DISS_acceptance">
								<xsl:value-of select="1"/>
							</xsl:if>
						</xsl:variable>
						<xsl:if test="number($accept) != 0">
								<xsl:variable name="pdfpath">
									<xsl:value-of select="DISS_content/DISS_binary"/>
								</xsl:variable>
								<xsl:value-of
									select="concat('https://location-of-PDFS-on-your-public-server', $pdfpath)"
								/>
						</xsl:if>
						
					</fulltext-url>

					<!-- Adds document type -->
					<document-type>
						<xsl:variable name="document">
							<xsl:value-of select="DISS_description/@type"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="starts-with(upper-case($document), 'D')">
								<xsl:value-of>dissertation</xsl:value-of>
							</xsl:when>
							<xsl:when test="starts-with(upper-case($document), 'M')">
								<xsl:value-of>thesis</xsl:value-of>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$document"/>
							</xsl:otherwise>
						</xsl:choose>
					</document-type>
							
					<!-- Crosswalks degree names -->
					<degree_name>
						<xsl:for-each select="DISS_description/DISS_degree">
							<xsl:variable name="degstring">
								<xsl:value-of select="."/>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="contains($degstring,'D.B.A.')">
									<xsl:value-of select="replace($degstring, 'D.B.A.','Doctor of Business Administration (D.B.A.)')"/>
								</xsl:when>
								<xsl:when test="contains($degstring,'E.X.')">
									<xsl:value-of select="replace($degstring, 'E.X.','Add more rows for additional degrees, EX')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$degstring"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</degree_name>

					<!-- Normalizes department names -->
					<department>
						<xsl:for-each select="DISS_description/DISS_institution/DISS_inst_contact">
							<xsl:variable name="deptstring">
								<xsl:value-of select="."/>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="contains($deptstring, '&amp;')">
									<xsl:value-of select="replace($deptstring, '&amp;', 'and')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$deptstring"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</department>

					<!-- add abstract format - testing  -->
					<abstract_format>html</abstract_format>

					<fields>

						<!-- add language - add additional spelled out forms of ISO 639-1 codes as needed -->
						<field name="language" type="string">
							<value>
								<xsl:value-of select="DISS_description/DISS_categorization/DISS_language"/>
							</value>
						</field>

						<field name="provenance" type="string">
							<value>Received from ProQuest</value>	
						</field>

						<!-- Rights info -->
						<field name="copyright_date" type="string">
							<value>
								<xsl:value-of select="DISS_description/DISS_dates/DISS_comp_date"/>
							</value>
						</field>
						
						<!-- Embargo date -->
						<field name="embargo_date" type="date">						
							<xsl:variable name="dateString">
								<xsl:value-of select="DISS_repository/DISS_delayed_release"/>
							</xsl:variable>
							<!-- shorten to just yyyy-mm-dd -->
							<value>
								<xsl:value-of select="substring($dateString,1,10)" />
							</value>
						</field>

						<!-- Pages numbers (from actual length of PDF, not based on page numbering) -->
						<field name="file_size" type="string">
							<value>
								<xsl:value-of select="concat(DISS_description/@page_count, ' p.')"/>
							</value>
						</field>
						
						<!-- Automatically sets fileformat to pdf -->
						<field name="fileformat" type="string">
							<value>application/pdf</value>
						</field>
						
						<field name="rights_holder" type="string">
							<value>
								<xsl:value-of
										select="DISS_authorship/DISS_author/DISS_name/DISS_fname"/>
									<xsl:text> </xsl:text>
									<xsl:value-of
										select="DISS_authorship/DISS_author/DISS_name/DISS_middle"/>
									<xsl:text> </xsl:text>
									<xsl:value-of
										select="DISS_authorship/DISS_author/DISS_name/DISS_surname"/>
									<xsl:text> </xsl:text>
									<xsl:value-of
										select="DISS_authorship/DISS_author/DISS_name/DISS_suffix"/>
							</value>			
						</field>	

						<!-- Advisors (up to 3 captured) -->
						<xsl:call-template name="advisor"/>
					</fields>
				</document>
			</xsl:for-each>
		</documents>
	</xsl:template>
		<xsl:template match="DISS_description" name="advisor">
		<xsl:if test="DISS_description/DISS_advisor[1]">
			<field name="advisor1" type="string">
				<value>
					<xsl:variable name="fname">
						<xsl:value-of select="DISS_description/DISS_advisor[1]/DISS_name/DISS_fname"
						/>
					</xsl:variable>
					<xsl:variable name="lname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[1]/DISS_name/DISS_surname"/>
					</xsl:variable>

					<xsl:variable name="mname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[1]/DISS_name/DISS_middle"/>
					</xsl:variable>
					<xsl:choose>
						<!-- ignore middle name when blank or single space -->
						<xsl:when test="$mname=''">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<xsl:when test="$mname=' '">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<!-- abbreviate middle name to initial -->
						<xsl:otherwise>
							<xsl:variable name="minitial">
								<xsl:value-of select="substring($mname,1,1)"/>
							</xsl:variable>
							<xsl:value-of select="concat($fname,' ',$minitial, '. ',$lname)"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</field>

		</xsl:if>
		<xsl:if test="DISS_description/DISS_advisor[2]">
			<field name="advisor2" type="string">
				<value>
					<xsl:variable name="fname">
						<xsl:value-of select="DISS_description/DISS_advisor[2]/DISS_name/DISS_fname"
						/>
					</xsl:variable>
					<xsl:variable name="lname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[2]/DISS_name/DISS_surname"/>
					</xsl:variable>

					<xsl:variable name="mname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[2]/DISS_name/DISS_middle"/>
					</xsl:variable>
					<xsl:choose>
						<!-- ignore middle name when blank or single space -->
						<xsl:when test="$mname=''">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<xsl:when test="$mname=' '">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<!-- abbreviate middle name to initial -->
						<xsl:otherwise>
							<xsl:variable name="minitial">
								<xsl:value-of select="substring($mname,1,1)"/>
							</xsl:variable>
							<xsl:value-of select="concat($fname,' ',$minitial, '. ',$lname)"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</field>
		</xsl:if>
		<xsl:if test="DISS_description/DISS-advisor[3]">
			<field name="advisor3" type="string">
				<value>
					<xsl:variable name="fname">
						<xsl:value-of select="DISS_description/DISS_advisor[3]/DISS_name/DISS_fname"
						/>
					</xsl:variable>
					<xsl:variable name="lname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[3]/DISS_name/DISS_surname"/>
					</xsl:variable>
					<xsl:variable name="mname">
						<xsl:value-of
							select="DISS_description/DISS_advisor[3]/DISS_name/DISS_middle"/>
					</xsl:variable>
					<xsl:choose>
						<!-- ignore middle name when blank or single space -->
						<xsl:when test="$mname=''">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<xsl:when test="$mname=' '">
							<xsl:value-of select="concat($fname, ' ', $lname)"/>
						</xsl:when>
						<!-- abbreviate middle name to initial -->
						<xsl:otherwise>
							<xsl:variable name="minitial">
								<xsl:value-of select="substring($mname,1,1)"/>
							</xsl:variable>
							<xsl:value-of select="concat($fname,' ',$minitial, '. ',$lname)"/>
						</xsl:otherwise>
					</xsl:choose>
				</value>
			</field>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>