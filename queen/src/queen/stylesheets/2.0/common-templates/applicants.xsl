<?xml version="1.0" encoding="UTF-8"?>

<!-- this xslt was created with reference to pat_common.xsl at Apr  4  2023 
     sha256sum:054dec3b453ed47edcc0732a4156c236344fbdece7d40d2eb669a8c0d1756d92 
-->

<xsl:stylesheet
    version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:xf="http://www.w3.org/2005/xpath-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <!-- ====================================================================
         申請者編集
         ====================================================================-->
    <xsl:template
        name="申請者編集">
        <xsl:param name="code" />
        
        <xf:string key="indentLevel">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:sequence select="2" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0" />
                </xsl:otherwise>
            </xsl:choose>
        </xf:string>
        
        <xsl:variable name="jpTag">
            <xsl:choose>
                <xsl:when test="./@jp:kind-of-application = 'appeal'">
                    <xsl:value-of select="'【審判請求人】'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:applicants">
                            <xsl:variable name="tmp" select="map:get($applicant-1-table, @code)" />
                            <xsl:choose>
                                <xsl:when test="$tmp">
                                    <xsl:value-of select="$tmp" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="substring($code,1,1) = 'C' ">
                                        <xsl:value-of select="'【審判請求人】'" />
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="map:get($applicant-2-table, @code)" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:string key="jpTag">
            <xsl:choose>
                <xsl:when test="$jpTag">
                    <xsl:value-of select="$jpTag" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'unknown'" />
                </xsl:otherwise>
            </xsl:choose>
        </xf:string>
    </xsl:template>
    
    <xsl:variable name="applicant-1-code" select="(
            map{ 'code': ('A151', 'A251', 'A1523', 'A2523'), 'value': '【補正をする者】'},
            map{ 'code': ('A263', 'A2632',
                    'A2633', 'A2634', 'A2635', 'A2761', 'A2762', 'A2764',
                    'A2765', 'A253', 'A2801', 'A2626', 'A25210', 'A25211',
                    'A25212', 'A2525', 'A2526', 'A2527', 'A2528', 'A2529',
                    'A2IB3491', 'A2917'), 'value': '【実用新案登録出願人】'},
            map{ 'code': ('A155', 'A255'), 'value': '【受継申立人】'},
            map{ 'code': ('A1681', 'A2681'), 'value': '【代表者】'},
            map{ 'code': ('A1711', 'A2711', 'A1712', 'A2712'), 'value': '【承継人】'},
            map{ 'code': ('A17421', 'A27421',
                    'A17422', 'A27422', 'A17423', 'A27423', 'A17424', 'A27424',
                    'A17425', 'A27425', 'A17426', 'A27426', 'A17427', 'A27427',
                    'A17428', 'A27428', 'A17431', 'A27431', 'A17432', 'A27432',
                    'A17433', 'A27433', 'A17434', 'A27434', 'A17435', 'A27435',
                    'A17436', 'A27436', 'A17437', 'A27437', 'A167', 'A1916', 'A2916'),
                'value':'【手続をした者】'},
            map{ 'code': ('A159', 'A259'), 'value': '【弁明をする者】'},
            map{ 'code': ('A179', 'A279',
                    'A180', 'A280', 'A181', 'A281', 'A182', 'A282',
                    'A1822', 'A2822', 'A1691', 'A2691', 'A1831', 'A2831',
                    'A187', 'A287', 'A1871', 'A2871', 'A1872', 'A2872'),
                'value': '【提出者】'},
            map{ 'code': ('A1601', 'A2601',
                    'A1621', 'A2621', 'A2623', 'A2624', 'A1625', 'A2625',
                    'E1841', 'E2841', 'E1842', 'E2842', 'E1851', 'E2851',
                    'E1852', 'E2852', 'E1853', 'E2853', 'E3853', 'E4853',
                    'E1854', 'E2854', 'E3854', 'E4854', 'E1861', 'E2861',
                    'E1862', 'E2862', 'E3862', 'E4862', 'A1603', 'A2603'),
                'value': '【請求人】'},
            map{ 'code': ('A1781', 'A2781'), 'value': '【上申をする者】'},
            map{ 'code': ('A1821', 'A2821', 'R4220'), 'value': '【補足をする者】'},
            map{ 'code': ('R4201', 'R4211'), 'value': '【更新登録申請人】'},
            map{ 'code': ('R1100', 'R2100',
                    'R3100', 'R4100', 'R1101', 'R3102', 'R4103', 'R4104',
                    'R4105', 'R1110', 'R2110', 'R3110', 'R4110', 'R1111',
                    'R3112', 'R4113', 'R4114', 'R4115', 'R120', 'R220',
                    'R320', 'R4200', 'R121', 'R221', 'R321', 'R4210'), 'value': '【納付者】'},
            map{ 'code': ('A163', 'A1631',
                    'A1632', 'A1634', 'A1635', 'A1761', 'A1762', 'A1764',
                    'A1765', 'A153', 'A1801', 'A1627', 'A15210', 'A15211',
                    'A15212', 'A1524', 'A1525', 'A1526', 'A1527', 'A1528',
                    'A1529', 'A1IB3491', 'A1917'), 'value': '【特許出願人】'},
            map{ 'code': ('C16543', 'C26543', 'C36543', 'C46543'), 'value': '【回答者】'},
            map{ 'code': ('C16573', 'C26573', 'C36573', 'C46573'), 'value': '【鑑定人】'},
            map{ 'code': ('C16592', 'C26592', 'C36592', 'C46592'), 'value': '【証人】'},
            map{ 'code': ('C1875', 'C2875'), 'value': '【返還請求人】'},
            map{'code': ('A1914', 'A1915', 'A2915'), 'value': '【申出人】'}
        )"/>
    <xsl:variable name="applicant-1-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$applicant-1-code" />
        </xsl:call-template>
   </xsl:variable>
    
    <xsl:variable name="applicant-2-code" select="(
            map{ 'code': ('R1100', 'R1101', 'R1110', 'R1111'),'value': '【特許出願人】'},
            map{ 'code': ('R2100', 'R2110'),'value': '【実用新案登録出願人】'},
            map{ 'code': ('R3100', 'R3102', 'R3110', 'R3112'),'value': '【意匠登録出願人】'},
            map{ 'code': ('R4100', 'R4110'),'value': '【商標登録出願人】'},
            map{ 'code': ('R4103', 'R4113'),'value': '【防護標章登録出願人】'},
            map{ 'code': ('R4104', 'R4114'),'value': '【更新登録出願人】'},
            map{ 'code': ('R4105', 'R4115'),'value': '【防護標章更新登録出願人】'},
            map{ 'code': ('R120', 'R121'),'value': '【特許権者】'},
            map{ 'code': ('R220', 'R221'),'value': '【実用新案権者】'},
            map{ 'code': ('R320', 'R321'),'value': '【意匠権者】'},
            map{ 'code': ('R4200', 'R4210'),'value': '【商標権者】'},
            map{ 'code': ('A1711', 'A2711'),'value': '【譲渡人】'},
            map{ 'code': ('A1712', 'A2712'),'value': '【被承継人】'},
            map{ 'code': ('A17422', 'A27422',
                    'A17424', 'A27424', 'A17431', 'A27431',
                    'A17432', 'A27432', 'A17433', 'A27433',
                    'A17434', 'A27434', 'A17435', 'A27435',
                    'A17436', 'A27436', 'A17437', 'A27437'), 'value': '【手続をした者】'}
        )"/>
    <xsl:variable name="applicant-2-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$applicant-2-code" />
        </xsl:call-template>
   </xsl:variable>
</xsl:stylesheet>
