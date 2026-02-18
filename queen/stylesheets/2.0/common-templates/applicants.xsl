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
    xmlns:xf="http://www.w3.org/2005/xpath-functions">
    
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
        
        <xf:string key="jpTag">
            <xsl:choose>
                <xsl:when test="./@jp:kind-of-application = 'appeal'">
                    <xsl:value-of select="'【審判請求人】'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:applicants">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A151' or $code = 'A251'
                                        or $code = 'A1523' or $code = 'A2523'">
                                    <xsl:value-of select="'【補正をする者】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A263' or $code = 'A2632'
                                        or $code = 'A2633' or $code = 'A2634' or $code = 'A2635'
                                        or $code = 'A2761' or $code = 'A2762' or $code = 'A2764'
                                        or $code = 'A2765' or $code = 'A253' or $code = 'A2801'
                                        or $code = 'A2626' or $code = 'A25210' or $code = 'A25211'
                                        or $code = 'A25212' or $code = 'A2525' or $code = 'A2526'
                                        or $code = 'A2527' or $code = 'A2528' or $code = 'A2529'
                                        or $code = 'A2IB3491'
                                        or $code = 'A2917'">
                                    <xsl:value-of select="'【実用新案登録出願人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A155' or $code = 'A255'">
                                    <xsl:value-of select="'【受継申立人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A1681' or $code = 'A2681'">
                                    <xsl:value-of select="'【代表者】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A1711' or $code = 'A2711'
                                        or $code = 'A1712' or $code = 'A2712'">
                                    <xsl:value-of select="'【承継人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17421' or $code = 'A27421'
                                        or $code = 'A17422' or $code = 'A27422'
                                        or $code = 'A17423' or $code = 'A27423'
                                        or $code = 'A17424' or $code = 'A27424'
                                        or $code = 'A17425' or $code = 'A27425'
                                        or $code = 'A17426' or $code = 'A27426'
                                        or $code = 'A17427' or $code = 'A27427'
                                        or $code = 'A17428' or $code = 'A27428'
                                        or $code = 'A17431' or $code = 'A27431'
                                        or $code = 'A17432' or $code = 'A27432'
                                        or $code = 'A17433' or $code = 'A27433'
                                        or $code = 'A17434' or $code = 'A27434'
                                        or $code = 'A17435' or $code = 'A27435'
                                        or $code = 'A17436' or $code = 'A27436'
                                        or $code = 'A17437' or $code = 'A27437'
                                        or $code = 'A167'
                                        or $code = 'A1916' or $code = 'A2916'">
                                    <xsl:value-of select="'【手続をした者】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A159' or $code = 'A259'">
                                    <xsl:value-of select="'【弁明をする者】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A179' or $code = 'A279'
                                        or $code = 'A180' or $code = 'A280'
                                        or $code = 'A181' or $code = 'A281'
                                        or $code = 'A182' or $code = 'A282'
                                        or $code = 'A1822' or $code = 'A2822'
                                        or $code = 'A1691' or $code = 'A2691'
                                        or $code = 'A1831' or $code = 'A2831'
                                        or $code = 'A187' or $code = 'A287'
                                        or $code = 'A1871' or $code = 'A2871'
                                        or $code = 'A1872' or $code = 'A2872'">
                                    <xsl:value-of select="'【提出者】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A1601' or $code = 'A2601'
                                        or $code = 'A1621' or $code = 'A2621'
                                        or $code = 'A2623'
                                        or $code = 'A2624'
                                        or $code = 'A1625' or $code = 'A2625'
                                        or $code = 'E1841' or $code = 'E2841'
                                        or $code = 'E1842' or $code = 'E2842'
                                        or $code = 'E1851' or $code = 'E2851'
                                        or $code = 'E1852' or $code = 'E2852'
                                        or $code = 'E1853' or $code = 'E2853'
                                        or $code = 'E3853' or $code = 'E4853'
                                        or $code = 'E1854' or $code = 'E2854'
                                        or $code = 'E3854' or $code = 'E4854'
                                        or $code = 'E1861' or $code = 'E2861'
                                        or $code = 'E1862' or $code = 'E2862'
                                        or $code = 'E3862' or $code = 'E4862'
                                        or $code = 'A1603' or $code = 'A2603'">
                                    <xsl:value-of select="'【請求人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A1781' or $code = 'A2781'">
                                    <xsl:value-of select="'【上申をする者】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A1821' or $code = 'A2821'
                                        or $code = 'R4220'">
                                    <xsl:value-of select="'【補足をする者】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R4201' or $code = 'R4211'">
                                    <xsl:value-of select="'【更新登録申請人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'R1100' or $code = 'R2100'
                                        or $code = 'R3100' or $code = 'R4100'
                                        or $code = 'R1101' or $code = 'R3102'
                                        or $code = 'R4103' or $code = 'R4104'
                                        or $code = 'R4105'
                                        or $code = 'R1110' or $code = 'R2110'
                                        or $code = 'R3110' or $code = 'R4110'
                                        or $code = 'R1111' or $code = 'R3112'
                                        or $code = 'R4113' or $code = 'R4114'
                                        or $code = 'R4115'
                                        or $code = 'R120' or $code = 'R220'
                                        or $code = 'R320'
                                        or $code = 'R4200'
                                        or $code = 'R121' or $code = 'R221'
                                        or $code = 'R321'
                                        or $code = 'R4210'">
                                    <xsl:value-of select="'【納付者】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A163' or $code = 'A1631'
                                        or $code = 'A1632' or $code = 'A1634' or $code = 'A1635'
                                        or $code = 'A1761' or $code = 'A1762' or $code = 'A1764'
                                        or $code = 'A1765' or $code = 'A153' or $code = 'A1801'
                                        or $code = 'A1627' or $code = 'A15210' or $code = 'A15211'
                                        or $code = 'A15212' or $code = 'A1524' or $code = 'A1525'
                                        or $code = 'A1526' or $code = 'A1527' or $code = 'A1528'
                                        or $code = 'A1529' or $code = 'A1IB3491'
                                        or $code = 'A1917'">
                                    <xsl:value-of select="'【特許出願人】'" />
                                </xsl:when>
                                <xsl:when test="substring($code,1,1) = 'C' ">
                                    <xsl:choose>
                                        <xsl:when
                                            test="$code = 'C16543' or $code = 'C26543'
                                                or $code = 'C36543' or $code = 'C46543'">
                                            <xsl:value-of select="'【回答者】'" />
                                        </xsl:when>
                                        <xsl:when
                                            test="$code = 'C16573' or $code = 'C26573'
                                                or $code = 'C36573' or $code = 'C46573'">
                                            <xsl:value-of select="'【鑑定人】'" />
                                        </xsl:when>
                                        <xsl:when
                                            test="$code = 'C16592' or $code = 'C26592'
                                                or $code = 'C36592' or $code = 'C46592'">
                                            <xsl:value-of select="'【証人】'" />
                                        </xsl:when>
                                        <xsl:when test="$code = 'C1875' or $code = 'C2875'">
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'【審判請求人】'" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A1914' or $code = 'A1915' or $code = 'A2915'">
                                    <xsl:value-of select="'【返還請求人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A1918' or $code = 'A1919'">
                                    <xsl:value-of select="'【申出人】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'R1100' or $code = 'R1101'
                                        or $code = 'R1110' or $code = 'R1111'">
                                    <xsl:value-of select="'【特許出願人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R2100' or $code = 'R2110'">
                                    <xsl:value-of select="'【実用新案登録出願人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'R3100' or $code = 'R3102'
                                        or $code = 'R3110' or $code = 'R3112'">
                                    <xsl:value-of select="'【意匠登録出願人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R4100' or $code = 'R4110'">
                                    <xsl:value-of select="'【商標登録出願人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R4103' or $code = 'R4113'">
                                    <xsl:value-of select="'【防護標章登録出願人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R4104' or $code = 'R4114'">
                                    <xsl:value-of select="'【更新登録出願人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R4105' or $code = 'R4115'">
                                    <xsl:value-of select="'【防護標章更新登録出願人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R120' or $code = 'R121'">
                                    <xsl:value-of select="'【特許権者】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R220' or $code = 'R221'">
                                    <xsl:value-of select="'【実用新案権者】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R320' or $code = 'R321'">
                                    <xsl:value-of select="'【意匠権者】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'R4200' or $code = 'R4210'">
                                    <xsl:value-of select="'【商標権者】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A1711' or $code = 'A2711'">
                                    <xsl:value-of select="'【譲渡人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A1712' or $code = 'A2712'">
                                    <xsl:value-of select="'【被承継人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17422' or $code = 'A27422'
                                        or $code = 'A17424' or $code = 'A27424'
                                        or $code = 'A17431' or $code = 'A27431'
                                        or $code = 'A17432' or $code = 'A27432'
                                        or $code = 'A17433' or $code = 'A27433'
                                        or $code = 'A17434' or $code = 'A27434'
                                        or $code = 'A17435' or $code = 'A27435'
                                        or $code = 'A17436' or $code = 'A27436'
                                        or $code = 'A17437' or $code = 'A27437'">
                                    <xsl:value-of select="'【手続をした者】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xf:string>
    </xsl:template>
</xsl:stylesheet>