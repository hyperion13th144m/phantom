<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="urn:phantom-mona:string-utils"
                xmlns:xf="http://www.w3.org/2005/xpath-functions"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <!-- this xslt was created with reference to pat_common.xsl at Apr  4  2023 
         sha256sum:054dec3b453ed47edcc0732a4156c236344fbdece7d40d2eb669a8c0d1756d92 
    -->
    
    
    <!-- ====================================================================
         代理人編集
         ====================================================================-->
    <xsl:template name="代理人編集">
        <xsl:param name="code" />
        
        <xsl:variable name="agent-string">
            <xsl:choose>
                <xsl:when test="./@jp:kind-of-agent">
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:proceeded-attorney-article">
                            <xsl:value-of select="map:get($prefix-1-table, @code)" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:agents">
                            <xsl:choose>
                                <xsl:when test="substring($code,1,1) = 'C'">
                                    <xsl:value-of select="'【'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="map:get($prefix-2-table, @code)" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-of-case-article">
                            <xsl:value-of select="map:get($prefix-3-table, @code)" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-change-article">
                            <xsl:value-of select="map:get($prefix-4-table, @code)" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-disappear-article">
                            <xsl:value-of select="map:get($prefix-5-table, @code)" />
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="./@jp:kind-of-agent = 'representative'">
                            <xsl:value-of select="'代理人'" />
                        </xsl:when>
                        <xsl:when test="./@jp:kind-of-agent = 'sub-representative'">
                            <xsl:value-of select="'復代理人'" />
                        </xsl:when>
                        <xsl:when test="./@jp:kind-of-agent = 'legal-representative'">
                            <xsl:value-of select="'法定代理人'" />
                        </xsl:when>
                        <xsl:when test="./@jp:kind-of-agent = 'designated-representative'">
                            <xsl:value-of select="'指定代理人'" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="./@jp:kind-of-agent" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="'】'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:proceeded-attorney-article">
                            <xsl:value-of select="map:get($agent-1-table, @code)" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:agents">
                            <xsl:value-of select="map:get($agent-2-table, @code)" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-of-case-article">
                            <xsl:value-of select="map:get($agent-3-table, @code)" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-change-article">
                            <xsl:value-of select="map:get($agent-4-table, @code)" />
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-disappear-article">
                            <xsl:value-of select="map:get($agent-5-table, @code)" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="base-num-of-spaces" as="xs:integer">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:sequence select="2" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="num-of-spaces" as="xs:integer">
            <xsl:choose>
                <xsl:when test="./@jp:kind-of-agent">
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:attorney-change-article">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A17421' or $code = 'A27421'
                                        or $code = 'A17423' or $code = 'A27423'
                                        or $code = 'A17431' or $code = 'A27431'
                                        or $code = 'A17433' or $code = 'A27433'">
                                    <xsl:choose>
                                        <xsl:when test="ancestor::jp:contents-of-amendment">
                                            <xsl:sequence select="0" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="2" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17425' or $code = 'A27425'
                                        or $code = 'A17435' or $code = 'A27435'">
                                    <xsl:choose>
                                        <xsl:when test="ancestor::jp:contents-of-amendment">
                                            <xsl:sequence select="0" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="2" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17426' or $code = 'A27426'
                                        or $code = 'A17436' or $code = 'A27436'">
                                    <xsl:choose>
                                        <xsl:when test="ancestor::jp:contents-of-amendment">
                                            <xsl:sequence select="0" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="2" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17427' or $code = 'A27427'
                                        or $code = 'A17437' or $code = 'A27437'">
                                    <xsl:choose>
                                        <xsl:when test="ancestor::jp:contents-of-amendment">
                                            <xsl:sequence select="0" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="2" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$code = 'A17428' or $code = 'A27428'">
                                    <xsl:choose>
                                        <xsl:when test="ancestor::jp:contents-of-amendment">
                                            <xsl:sequence select="0" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="2" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="0" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-disappear-article">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A17421' or $code = 'A27421'
                                        or $code = 'A17431' or $code = 'A27431'">
                                    <xsl:choose>
                                        <xsl:when test="ancestor::jp:contents-of-amendment">
                                            <xsl:sequence select="0" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="2" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="0" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="0" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xf:string key="jpTag">
            <xsl:choose>
                <xsl:when test="$agent-string">
                    <xsl:value-of select="$agent-string" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'unknown'" />
                </xsl:otherwise>
            </xsl:choose>
        </xf:string>
        <xf:string key="indentLevel">
            <xsl:value-of select="$base-num-of-spaces + $num-of-spaces" />
        </xf:string>
    </xsl:template>
    
    <xsl:variable name="prefix-1-code" select="(
            map{ 'code': ('A17422', 'A27422', 'A17432', 'A27432'), 'value': '【受任した'},
            map{ 'code': ('A17424', 'A27424', 'A17434', 'A27434'), 'value': '【辞任した'},
            map{ 'code': ('A17431', 'A27431', 'A17433', 'A27433',
                    'A17435', 'A27435', 'A17436', 'A27436', 'A17437', 'A27437'), 'value': '【'}
        )"/>
    <xsl:variable name="prefix-1-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$prefix-1-code" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="prefix-2-code" select="(
            map{ 'code': ('A1711', 'A2711', 'A1712', 'A2712'), 'value': '【承継人'},
            map{ 'code': ('A163', 'A263',
                    'A1631', 'A1632', 'A2632', 'A2633', 'A1634', 'A2634',
                    'A1635', 'A2635', 'A155', 'A255',  'A1681', 'A2681',
                    'A17421', 'A27421', 'A17423', 'A27423', 'A17425', 'A27425',
                    'A17426', 'A27426', 'A17427', 'A27427', 'A17428', 'A27428',
                    'A1761', 'A2761', 'A1762', 'A2762', 'A1764', 'A2764',
                    'A1765', 'A2765', 'A153', 'A253', 'A159', 'A259',
                    'A179', 'A279', 'A180', 'A280', 'A1801', 'A2801',
                    'A181', 'A281', 'A182', 'A282', 'A1822', 'A2822',
                    'A1601', 'A2601', 'A1621', 'A2621', 'A2623',
                    'A1625', 'A2625', 'A1625', 'A2625', 'A2626',
                    'A1627', 'A167', 'A1691', 'A2691', 'A1781', 'A2781',
                    'A1821', 'A2821', 'A1831', 'A2831', 'A187', 'A287',
                    'A1871', 'A2871', 'A1872', 'A2872', 'A151', 'A251',
                    'A15210', 'A25210', 'A15211', 'A25211',
                    'A15212', 'A25212', 'A1523', 'A2523',
                    'A1524', 'A2524', 'A1525', 'A2525',
                    'A1526', 'A2526', 'A1527', 'A2527',
                    'A1528', 'A2528', 'A1529', 'A2529',
                    'R1100', 'R2100', 'R3100', 'R4100',
                    'R1101', 'R3102', 'R4103', 'R4104',
                    'R4105', 'R1110', 'R2110', 'R3110', 'R4110',
                    'R1111', 'R3112', 'R4113', 'R4114', 'R4115',
                    'R120', 'R220', 'R320', 'R4200', 'R4201',
                    'R121', 'R221','R321', 'R4210',
                    'R4211', 'R4220', 'A1IB3491', 'A2IB3491', 'A1914',
                    'A1915', 'A2915', 'A2624','A1916', 'A2916',
                    'A1603', 'A2603', 'A1917', 'A2917', 'A1918', 'A1919'), 'value': '【'}
        )"/>
    <xsl:variable name="prefix-2-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$prefix-2-code" />
        </xsl:call-template>
   </xsl:variable>
    
    <xsl:variable name="prefix-3-code" select="(
            map{ 'code': ('A1711', 'A2711'), 'value': '【譲渡人'},
            map{ 'code': ('A1712', 'A2712'), 'value': '【被承継人'},
            map{ 'code': ('A17432', 'A27432', 'A17434', 'A27434'), 'value': '【'}
        )"/>
    <xsl:variable name="prefix-3-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$prefix-3-code" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="prefix-4-code" select="(
            map{ 'code': ('A163', 'A263',
                    'A1632', 'A2632', 'A1711', 'A2711', 'A1712', 'A2712',
                    'C160', 'C260', 'C360', 'C4660'), 'value': '【選任した'},
            map{ 'code': ('A17421', 'A27421', 'A17423', 'A27423',
                    'A17431', 'A27431', 'A17433', 'A27433'), 'value': '【選任した'},
            map{ 'code': ('A17425', 'A27425', 'A17435', 'A27435'), 'value': '【解任した'},
            map{ 'code': ('A17426', 'A27426', 'A17436', 'A27436'), 'value': '【代理権を変更した'},
            map{ 'code': ('A17427', 'A27427', 'A17437', 'A27437'), 'value': '【代理権の消滅した'},
            map{ 'code': ('A17428', 'A27428'), 'value': '【援用を制限した'}
        )"/>
    <xsl:variable name="prefix-4-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$prefix-4-code" />
        </xsl:call-template>
   </xsl:variable>
    
    <xsl:variable name="prefix-5-code-1" select="'A17421', 'A27421',
        'A17431', 'A27431'"/>
    <xsl:variable name="prefix-5-table" as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:for-each select="$prefix-5-code-1">
                <xsl:map-entry key="." select="'【代理権の消滅した'" />
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <xsl:variable name="agent-1-code" select="(
            map{ 'code': ('A17422', 'A27422'), 'value': '【受任した代理人】'},
            map{ 'code': ('A17424', 'A27424'), 'value': '【辞任した代理人】'},
            map{ 'code': ('A17432', 'A27432'), 'value': '【受任した復代理人】'},
            map{ 'code': ('A17434', 'A27434'), 'value': '【辞任した代理人】'},
            map{ 'code': ('A17431', 'A27431','A17433', 'A27433',
                    'A17435', 'A27435', 'A17436', 'A27436', 'A17437', 'A27437'),
                'value': '【代理人】'}
        )"/>
    <xsl:variable name="agent-1-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$agent-1-code" />
        </xsl:call-template>
    </xsl:variable>
    
    
    <xsl:variable name="agent-2-code" select="(
            map{ 'code': ('A1711', 'A2711','A1712', 'A2712'), 'value': '【承継人代理人】'},
            map{ 'code': ('A163', 'A263',
                    'A1631', 'A1632', 'A2632', 'A2633', 'A1634', 'A2634',
                    'A1635', 'A2635', 'A155', 'A255', 'A1681', 'A2681',
                    'A17421', 'A27421', 'A17423', 'A27423', 'A17425',
                    'A27425', 'A17426', 'A27426', 'A17427', 'A27427',
                    'A17428', 'A27428', 'A1761', 'A2761', 'A1762', 'A2762',
                    'A1764', 'A2764', 'A1765', 'A2765', 'A153', 'A253',
                    'A159', 'A259', 'A179', 'A279', 'A180', 'A280',
                    'A1801', 'A2801', 'A181', 'A281', 'A182', 'A282',
                    'A1822', 'A2822', 'A1601', 'A2601', 'A1621', 'A2621',
                    'A2623', 'A1625', 'A2625', 'A1625', 'A2625', 'A2626',
                    'A1627', 'A167', 'A1691', 'A2691', 'A1781', 'A2781',
                    'A1821', 'A2821', 'A1831', 'A2831', 'A187', 'A287',
                    'A1871', 'A2871', 'A1872', 'A2872', 'A151', 'A251',
                    'A15210', 'A25210', 'A15211', 'A25211', 'A15212',
                    'A25212', 'A1523', 'A2523', 'A1524', 'A1525', 'A2525',
                    'A1526', 'A2526', 'A1527', 'A2527', 'A1528', 'A2528',
                    'A1529', 'A2529', 'R1100', 'R2100', 'R3100', 'R4100',
                    'R1101', 'R3102', 'R4103', 'R4104', 'R4105', 'R1110',
                    'R2110', 'R3110', 'R4110', 'R1111', 'R3112', 'R4113',
                    'R4114', 'R4115', 'R120', 'R220', 'R320', 'R4200',
                    'R4201', 'R121', 'R221', 'R321', 'R4210', 'R4211',
                    'R4220', 'A1IB3491', 'A2IB3491', 'A1914', 'A1915',
                    'A2915', 'A2624', 'A1916', 'A2916', 'A1603', 'A2603',
                    'A1917', 'A2917', 'A1918', 'A1919'), 'value': '【承継人代理人】'}
        )"/>
    <xsl:variable name="agent-2-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$agent-2-code" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="agent-3-code" select="(
            map{ 'code': ('A1711', 'A2711'), 'value': '【譲渡人代理人】'},
            map{ 'code': ('A1712', 'A2712'), 'value': '【被承継人代理人】'},
            map{ 'code': ('A17432', 'A27432', 'A17434', 'A27434'), 'value': '【代理人】'}
        )"/>
    <xsl:variable name="agent-3-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$agent-3-code" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="agent-4-code" select="(
            map{ 'code': ('A163', 'A263', 'A1632', 'A2632', 'A1711', 'A2711', 'A1712', 'A2712', 'A17421', 'A27421', 'A17423', 'A27423'), 'value': '【選任した代理人】'},
            map{ 'code': ('A17425', 'A27425'), 'value': '【解任した代理人】'},
            map{ 'code': ('A17426', 'A27426'), 'value': '【代理権を変更した代理人】'},
            map{ 'code': ('A17427', 'A27427'), 'value': '【代理権の消滅した代理人】'},
            map{ 'code': ('A17428', 'A27428'), 'value': '【援用を制限した代理人】'},
            map{ 'code': ('A17431', 'A27431', 'A17433', 'A27433'), 'value': '【選任した復代理人】'},
            map{ 'code': ('A17435', 'A27435'), 'value': '【解任した復代理人】'},
            map{ 'code': ('A17436', 'A27436'), 'value': '【代理権を変更した復代理人】'},
            map{ 'code': ('A17437', 'A27437'), 'value': '【代理権の消滅した復代理人】'}
        )"/>
    <xsl:variable name="agent-4-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$agent-4-code" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="agent-5-code" select="(
            map{ 'code': ('A17421', 'A27421'), 'value': '【代理権の消滅した代理人】'},
            map{ 'code': ('A17431', 'A27431'), 'value': '【代理権の消滅した復代理人】'}
        )"/>
    <xsl:variable name="agent-5-table" as="map(xs:string, xs:string)">
        <xsl:call-template name="create-table">
            <xsl:with-param name="code" select="$agent-5-code" />
        </xsl:call-template>
    </xsl:variable>
</xsl:stylesheet>
