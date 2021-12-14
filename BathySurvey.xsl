<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

<!-- (c) 2010, Trimble Navigation Limited. All rights reserved.                                -->
<!-- Permission is hereby granted to use, copy, modify, or distribute this style sheet for any -->
<!-- purpose and without fee, provided that the above copyright notice appears in all copies   -->
<!-- and that both the copyright notice and the limited warranty and restricted rights notice  -->
<!-- below appear in all supporting documentation.                                             -->

<!-- TRIMBLE NAVIGATION LIMITED PROVIDES THIS STYLE SHEET "AS IS" AND WITH ALL FAULTS.         -->
<!-- TRIMBLE NAVIGATION LIMITED SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY -->
<!-- OR FITNESS FOR A PARTICULAR USE. TRIMBLE NAVIGATION LIMITED DOES NOT WARRANT THAT THE     -->
<!-- OPERATION OF THIS STYLE SHEET WILL BE UNINTERRUPTED OR ERROR FREE.                        -->

<xsl:output method="text" omit-xml-declaration="yes" encoding="ISO-8859-1"/>

<!-- Set the numeric display details i.e. decimal point, thousands separator etc -->
<xsl:variable name="DecPt" select="'.'"/>    <!-- Change as appropriate for US/European -->
<xsl:variable name="GroupSep" select="','"/> <!-- Change as appropriate for US/European -->
<!-- Also change decimal-separator & grouping-separator in decimal-format below 
     as appropriate for US/European output -->
<xsl:decimal-format name="Standard" 
                    decimal-separator="."
                    grouping-separator=","
                    infinity="Infinity"
                    minus-sign="-"
                    NaN=""
                    percent="%"
                    per-mille="&#2030;"
                    zero-digit="0" 
                    digit="#" 
                    pattern-separator=";" />

<xsl:variable name="DecPl0" select="'#0'"/>
<xsl:variable name="DecPl1" select="concat('#0', $DecPt, '0')"/>
<xsl:variable name="DecPl2" select="concat('#0', $DecPt, '00')"/>
<xsl:variable name="DecPl3" select="concat('#0', $DecPt, '000')"/>
<xsl:variable name="DecPl4" select="concat('#0', $DecPt, '0000')"/>
<xsl:variable name="DecPl5" select="concat('#0', $DecPt, '00000')"/>
<xsl:variable name="DecPl8" select="concat('#0', $DecPt, '00000000')"/>

<xsl:variable name="fileExt" select="'csv'"/>

<!-- User variable definitions - Appropriate fields are displayed on the       -->
<!-- Survey Controller screen to allow the user to enter specific values       -->
<!-- which can then be used within the style sheet definition to control the   -->
<!-- output data.                                                              -->
<!--                                                                           -->
<!-- All user variables must be identified by a variable element definition    -->
<!-- named starting with 'userField' (case sensitive) followed by one or more  -->
<!-- characters uniquely identifying the user variable definition.             -->
<!--                                                                           -->
<!-- The text within the 'select' field for the user variable description      -->
<!-- references the actual user variable and uses the '|' character to         -->
<!-- separate the definition details into separate fields as follows:          -->
<!-- For all user variables the first field must be the name of the user       -->
<!-- variable itself (this is case sensitive) and the second field is the      -->
<!-- prompt that will appear on the Survey Controller screen.                  -->
<!-- The third field defines the variable type - there are four possible       -->
<!-- variable types: Double, Integer, String and StringMenu.  These variable   -->
<!-- type references are not case sensitive.                                   -->
<!-- The fields that follow the variable type change according to the type of  -->
<!-- variable as follow:                                                       -->
<!-- Double and Integer: Fourth field = optional minimum value                 -->
<!--                     Fifth field = optional maximum value                  -->
<!--   These minimum and maximum values are used by the Survey Controller for  -->
<!--   entry validation.                                                       -->
<!-- String: No further fields are needed or used.                             -->
<!-- StringMenu: Fourth field = number of menu items                           -->
<!--             Remaining fields are the actual menu items - the number of    -->
<!--             items provided must equal the specified number of menu items. -->
<!--                                                                           -->
<!-- The style sheet must also define the variable itself, named according to  -->
<!-- the definition.  The value within the 'select' field will be displayed in -->
<!-- the Survey Controller as the default value for the item.                  -->
<!-- Some variables to control what GPS records are output -->
<xsl:variable name="userField1" select="'applyDepth|Apply depth to elevation?|stringMenu|4|High|Low|Single|No'"/>
<xsl:variable name="applyDepth" select="'No'"/>
<!-- **************************************************************** -->
<!-- Set global variables from the Environment section of JobXML file -->
<!-- **************************************************************** -->
<xsl:variable name="DistUnit"   select="/JOBFile/Environment/DisplaySettings/DistanceUnits" />
<xsl:variable name="AngleUnit"  select="/JOBFile/Environment/DisplaySettings/AngleUnits" />
<xsl:variable name="CoordOrder" select="/JOBFile/Environment/DisplaySettings/CoordinateOrder" />
<xsl:variable name="TempUnit"   select="/JOBFile/Environment/DisplaySettings/TemperatureUnits" />
<xsl:variable name="PressUnit"  select="/JOBFile/Environment/DisplaySettings/PressureUnits" />

<!-- Setup conversion factor for coordinate and distance values -->
<!-- Dist/coord values in JobXML file are always in metres -->
<xsl:variable name="DistConvFactor">
  <xsl:choose>
    <xsl:when test="$DistUnit='Metres'">1.0</xsl:when>
    <xsl:when test="$DistUnit='InternationalFeet'">3.280839895</xsl:when>
    <xsl:when test="$DistUnit='USSurveyFeet'">3.2808333333357</xsl:when>
    <xsl:otherwise>1.0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Setup conversion factor for angular values -->
<!-- Angular values in JobXML file are always in decimal degrees -->
<xsl:variable name="AngleConvFactor">
  <xsl:choose>
    <xsl:when test="$AngleUnit='DMSDegrees'">1.0</xsl:when>
    <xsl:when test="$AngleUnit='Gons'">1.111111111111</xsl:when>
    <xsl:when test="$AngleUnit='Mils'">17.77777777777</xsl:when>
    <xsl:otherwise>1.0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Setup boolean variable for coordinate order -->
<xsl:variable name="NECoords">
  <xsl:choose>
    <xsl:when test="$CoordOrder='North-East-Elevation'">true</xsl:when>
    <xsl:when test="$CoordOrder='X-Y-Z'">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Setup conversion factor for pressure values -->
<!-- Pressure values in JobXML file are always in millibars (hPa) -->
<xsl:variable name="PressConvFactor">
  <xsl:choose>
    <xsl:when test="$PressUnit='MilliBar'">1.0</xsl:when>
    <xsl:when test="$PressUnit='InchHg'">0.029529921</xsl:when>
    <xsl:when test="$PressUnit='mmHg'">0.75006</xsl:when>
    <xsl:otherwise>1.0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Set up a variable to indicate whether there are any point        -->
<!-- descriptions assigned to any points - zero means no descriptions -->
<!-- Only need to check for number of Description1 elements since     -->
<!-- both the Description1 and Description2 elements are output if    -->
<!-- either has been defined for the point.                           -->
<xsl:variable name="nbrPtDescriptions">
  <xsl:value-of select="count(JOBFile/Reductions/Point/Description1)"/>
</xsl:variable>

<!-- **************************************************************** -->
<!-- ************************** Main Loop *************************** -->
<!-- **************************************************************** -->
<xsl:template match="/" >
  <!-- Output an initial line showing what each of the values is -->
  <xsl:variable name="coordNames">
    <xsl:choose>
      <xsl:when test="$NECoords = 'true'">
        <xsl:text>North,East,Elevation</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>East,North,Elevation</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$nbrPtDescriptions = 0">
      <xsl:value-of select="concat('Pt name,', $coordNames, ',Depth single,Depth High,Depth Low,Depth applied elevation,Q,Code')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('Pt name,', $coordNames, ',Depth single,Depth High,Depth Low,Depth applied elevation,Q,Code,Description1,Description2')"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:call-template name="NewLine"/>

  <xsl:apply-templates select="JOBFile/FieldBook/PointRecord" />

</xsl:template>


<!-- **************************************************************** -->
<!-- *************** PointRecord Element Processing ***************** -->
<!-- **************************************************************** -->
<xsl:template match="PointRecord">
  <xsl:if test="Deleted = 'false'">
    <xsl:variable name="northStr" select="format-number(ComputedGrid/North * $DistConvFactor, $DecPl3, 'Standard')"/>
    <xsl:variable name="eastStr" select="format-number(ComputedGrid/East * $DistConvFactor, $DecPl3, 'Standard')"/>
    <xsl:variable name="elevStr" select="format-number(ComputedGrid/Elevation * $DistConvFactor, $DecPl3, 'Standard')"/>
    <xsl:variable name="depthStrh" select="format-number(CustomXmlSubRecord/CustomContent/Depth/High * $DistConvFactor, $DecPl3, 'Standard')"/>
	<xsl:variable name="depthStrl" select="format-number(CustomXmlSubRecord/CustomContent/Depth/Low * $DistConvFactor, $DecPl3, 'Standard')"/>
	<xsl:variable name="depthStr" select="format-number(CustomXmlSubRecord/CustomContent/Depth/Single * $DistConvFactor, $DecPl3, 'Standard')"/>
	<xsl:variable name="quality" select="format-number(CustomXmlSubRecord/CustomContent/Depth/Q, $DecPl3, 'Standard')"/>
    <!-- Note the Echo sounder draft correction is assumed to be in the output   -->
    <!-- units (not fixed to metres) so the DistConvFactor is not applied to it. -->
	<xsl:variable name="corrElevStr">
	  <xsl:choose>
		<xsl:when test="$applyDepth='High'">
			<xsl:value-of select="format-number((ComputedGrid/Elevation - CustomXmlSubRecord/CustomContent/Depth/High) * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:when>
		<xsl:when test="$applyDepth='Low'">
			<xsl:value-of select="format-number((ComputedGrid/Elevation - CustomXmlSubRecord/CustomContent/Depth/Low) * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:when>
		<xsl:when test="$applyDepth='Single'">
			<xsl:value-of select="format-number((ComputedGrid/Elevation - CustomXmlSubRecord/CustomContent/Depth/Single) * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:when>
		<xsl:otherwise></xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

    <!-- Output Point Name -->
    <xsl:value-of select="Name"/>
    <xsl:text>,</xsl:text>
    
    <!-- Output point coordinates - allowing for coordinate order -->
    <xsl:choose>
      <xsl:when test="$NECoords='true'">
        <xsl:value-of select="concat($northStr, ',', $eastStr, ',', $elevStr, ',')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($eastStr, ',', $northStr, ',', $elevStr, ',')"/>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Output depth -->
    <xsl:value-of select="$depthStr"/>
    <xsl:text>,</xsl:text>

	<!-- Output depth -->
    <xsl:value-of select="$depthStrl"/>
    <xsl:text>,</xsl:text>
	
	<!-- Output depth -->
    <xsl:value-of select="$depthStrh"/>
    <xsl:text>,</xsl:text>
	
	<!-- Output depth -->
    <xsl:value-of select="$corrElevStr"/>
    <xsl:text>,</xsl:text>
	
	<!-- Output depth -->
    <xsl:value-of select="$quality"/>
    <xsl:text>,</xsl:text>
	
    <!-- Output code -->
    <xsl:value-of select="Code"/>

    <!-- Output descriptions if appropriate -->
    <xsl:if test="$nbrPtDescriptions != 0">
      <xsl:text>,</xsl:text>
      <xsl:value-of select="Description1"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="Description2"/>
    </xsl:if>

    <xsl:call-template name="NewLine"/> <!-- New line ready for next point -->
  </xsl:if>
</xsl:template>


<!-- **************************************************************** -->
<!-- ********************** New Line Output ************************* -->
<!-- **************************************************************** -->
<xsl:template name="NewLine">
<xsl:text>&#10;</xsl:text>
</xsl:template>


</xsl:stylesheet>
