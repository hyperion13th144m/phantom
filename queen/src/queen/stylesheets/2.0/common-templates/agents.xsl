<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:phantom-mona:string-utils"
    xmlns:xf="http://www.w3.org/2005/xpath-functions">

    <xsl:output method="text" encoding="UTF-8" />

    <!-- this xslt was created with reference to pat_common.xsl at Apr  4  2023 
         sha256sum:054dec3b453ed47edcc0732a4156c236344fbdece7d40d2eb669a8c0d1756d92 
    -->


    <!-- ====================================================================
     代理人編集
     ====================================================================-->
    <xsl:template name="代理人編集">
        <xsl:param name="code" />

        <!--  項目名の編集  -->

        <xsl:variable name="agentKind">
            <xsl:choose>
                <xsl:when test="./@jp:kind-of-agent">
                    <xsl:choose>
                        <xsl:when test="ancestor::jp:proceeded-attorney-article">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A17422' or $code = 'A27422'
                         or $code = 'A17432' or $code = 'A27432'">
                                    <xsl:value-of select="'【受任した'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17424' or $code = 'A27424'
                         or $code = 'A17434' or $code = 'A27434'">
                                    <xsl:value-of select="'【辞任した'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17431' or $code = 'A27431'
                         or $code = 'A17433' or $code = 'A27433'
                         or $code = 'A17435' or $code = 'A27435'
                         or $code = 'A17436' or $code = 'A27436'
                         or $code = 'A17437' or $code = 'A27437'">
                                    <xsl:value-of select="'【'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:agents">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A1711' or $code = 'A2711'
                         or $code = 'A1712' or $code = 'A2712'">
                                    <xsl:value-of select="'【承継人'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A163' or $code = 'A263'
                         or $code = 'A1631'
                         or $code = 'A1632' or $code = 'A2632'
                         or $code = 'A2633'
                         or $code = 'A1634' or $code = 'A2634'
                         or $code = 'A1635' or $code = 'A2635'
                         or $code = 'A155' or $code = 'A255'
                         or $code = 'A1681' or $code = 'A2681'
                         or $code = 'A17421' or $code = 'A27421'
                         or $code = 'A17423' or $code = 'A27423'
                         or $code = 'A17425' or $code = 'A27425'
                         or $code = 'A17426' or $code = 'A27426'
                         or $code = 'A17427' or $code = 'A27427'
                         or $code = 'A17428' or $code = 'A27428'
                         or $code = 'A1761' or $code = 'A2761'
                         or $code = 'A1762' or $code = 'A2762'
                         or $code = 'A1764' or $code = 'A2764'
                         or $code = 'A1765' or $code = 'A2765'
                         or $code = 'A153' or $code = 'A253'
                         or $code = 'A159' or $code = 'A259'
                         or $code = 'A179' or $code = 'A279'
                         or $code = 'A180' or $code = 'A280'
                         or $code = 'A1801' or $code = 'A2801'
                         or $code = 'A181' or $code = 'A281'
                         or $code = 'A182' or $code = 'A282'
                         or $code = 'A1822' or $code = 'A2822'
                         or $code = 'A1601' or $code = 'A2601'
                         or $code = 'A1621' or $code = 'A2621'
                         or $code = 'A2623'
                         or $code = 'A1625' or $code = 'A2625'
                         or $code = 'A1625' or $code = 'A2625'
                         or $code = 'A2626'
                         or $code = 'A1627' or $code = 'A167'
                         or $code = 'A1691' or $code = 'A2691'
                         or $code = 'A1781' or $code = 'A2781'
                         or $code = 'A1821' or $code = 'A2821'
                         or $code = 'A1831' or $code = 'A2831'
                         or $code = 'A187' or $code = 'A287'
                         or $code = 'A1871' or $code = 'A2871'
                         or $code = 'A1872' or $code = 'A2872'
                         or $code = 'A151' or $code = 'A251'
                         or $code = 'A15210' or $code = 'A25210'
                         or $code = 'A15211' or $code = 'A25211'
                         or $code = 'A15212' or $code = 'A25212'
                         or $code = 'A1523' or $code = 'A2523'
                         or $code = 'A1524'
                         or $code = 'A1525' or $code = 'A2525'
                         or $code = 'A1526' or $code = 'A2526'
                         or $code = 'A1527' or $code = 'A2527'
                         or $code = 'A1528' or $code = 'A2528'
                         or $code = 'A1529' or $code = 'A2529'
                         or $code = 'R1100' or $code = 'R2100'
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
                         or $code = 'R320' or $code = 'R4200'
                         or $code = 'R4201'
                         or $code = 'R121' or $code = 'R221'
                         or $code = 'R321' or $code = 'R4210'
                         or $code = 'R4211' or $code = 'R4220'
                         or $code = 'A1IB3491' or $code = 'A2IB3491'
                         or substring($code,1,1) = 'C'
                         or $code = 'A1914'
                         or $code = 'A1915'or $code = 'A2915'
                         or $code = 'A2624'
                         or $code = 'A1916'or $code = 'A2916'
                         or $code = 'A1603'or $code = 'A2603'
                         or $code = 'A1917'or $code = 'A2917'
                         or $code = 'A1918'or $code = 'A1919'">
                                    <xsl:value-of select="'【'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-of-case-article">
                            <xsl:choose>
                                <xsl:when test="$code = 'A1711' or $code = 'A2711'">
                                    <xsl:value-of select="'【譲渡人'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A1712' or $code = 'A2712'">
                                    <xsl:value-of select="'【被承継人'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17432' or $code = 'A27432'
                         or $code = 'A17434' or $code = 'A27434'">
                                    <xsl:value-of select="'【'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-change-article">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A163' or $code = 'A263'
                         or $code = 'A1632' or $code = 'A2632'
                         or $code = 'A1711' or $code = 'A2711'
                         or $code = 'A1712' or $code = 'A2712'
                         or $code = 'C160' or $code = 'C260'
                         or $code = 'C360' or $code = 'C4660'">
                                    <xsl:value-of select="'【選任した'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17421' or $code = 'A27421'
                         or $code = 'A17423' or $code = 'A27423'
                         or $code = 'A17431' or $code = 'A27431'
                         or $code = 'A17433' or $code = 'A27433'">
                                    <xsl:value-of select="'【選任した'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17425' or $code = 'A27425'
                         or $code = 'A17435' or $code = 'A27435'">
                                    <xsl:value-of select="'【解任した'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17426' or $code = 'A27426'
                         or $code = 'A17436' or $code = 'A27436'">
                                    <xsl:value-of select="'【代理権を変更した'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17427' or $code = 'A27427'
                         or $code = 'A17437' or $code = 'A27437'">
                                    <xsl:value-of select="'【代理権の消滅した'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17428' or $code = 'A27428'">
                                    <xsl:value-of select="'【援用を制限した'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-disappear-article">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A17421' or $code = 'A27421'
                         or $code = 'A17431' or $code = 'A27431'">
                                    <xsl:value-of select="'【代理権の消滅した'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
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
                            <xsl:choose>
                                <xsl:when test="$code = 'A17422' or $code = 'A27422'">
                                    <xsl:value-of select="'【受任した代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17424' or $code = 'A27424'">
                                    <xsl:value-of select="'【辞任した代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17432' or $code = 'A27432'">
                                    <xsl:value-of select="'【受任した復代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17434' or $code = 'A27434'">
                                    <xsl:value-of select="'【辞任した代理人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17431' or $code = 'A27431'
                         or $code = 'A17433' or $code = 'A27433'
                         or $code = 'A17435' or $code = 'A27435'
                         or $code = 'A17436' or $code = 'A27436'
                         or $code = 'A17437' or $code = 'A27437'">
                                    <xsl:value-of select="'【代理人】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:agents">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A1711' or $code = 'A2711'
                         or $code = 'A1712' or $code = 'A2712'">
                                    <xsl:value-of select="'【承継人代理人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A163' or $code = 'A263'
                         or $code = 'A1631'
                         or $code = 'A1632' or $code = 'A2632'
                         or $code = 'A2633'
                         or $code = 'A1634' or $code = 'A2634'
                         or $code = 'A1635' or $code = 'A2635'
                         or $code = 'A155' or $code = 'A255'
                         or $code = 'A1681' or $code = 'A2681'
                         or $code = 'A17421' or $code = 'A27421'
                         or $code = 'A17423' or $code = 'A27423'
                         or $code = 'A17425' or $code = 'A27425'
                         or $code = 'A17426' or $code = 'A27426'
                         or $code = 'A17427' or $code = 'A27427'
                         or $code = 'A17428' or $code = 'A27428'
                         or $code = 'A1761' or $code = 'A2761'
                         or $code = 'A1762' or $code = 'A2762'
                         or $code = 'A1764' or $code = 'A2764'
                         or $code = 'A1765' or $code = 'A2765'
                         or $code = 'A153' or $code = 'A253'
                         or $code = 'A159' or $code = 'A259'
                         or $code = 'A179' or $code = 'A279'
                         or $code = 'A180' or $code = 'A280'
                         or $code = 'A1801' or $code = 'A2801'
                         or $code = 'A181' or $code = 'A281'
                         or $code = 'A182' or $code = 'A282'
                         or $code = 'A1822' or $code = 'A2822'
                         or $code = 'A1601' or $code = 'A2601'
                         or $code = 'A1621' or $code = 'A2621'
                         or $code = 'A2623'
                         or $code = 'A1625' or $code = 'A2625'
                         or $code = 'A1625' or $code = 'A2625'
                         or $code = 'A2626'
                         or $code = 'A1627' or $code = 'A167'
                         or $code = 'A1691' or $code = 'A2691'
                         or $code = 'A1781' or $code = 'A2781'
                         or $code = 'A1821' or $code = 'A2821'
                         or $code = 'A1831' or $code = 'A2831'
                         or $code = 'A187' or $code = 'A287'
                         or $code = 'A1871' or $code = 'A2871'
                         or $code = 'A1872' or $code = 'A2872'
                         or $code = 'A151' or $code = 'A251'
                         or $code = 'A15210' or $code = 'A25210'
                         or $code = 'A15211' or $code = 'A25211'
                         or $code = 'A15212' or $code = 'A25212'
                         or $code = 'A1523' or $code = 'A2523'
                         or $code = 'A1524'
                         or $code = 'A1525' or $code = 'A2525'
                         or $code = 'A1526' or $code = 'A2526'
                         or $code = 'A1527' or $code = 'A2527'
                         or $code = 'A1528' or $code = 'A2528'
                         or $code = 'A1529' or $code = 'A2529'
                         or $code = 'R1100' or $code = 'R2100'
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
                         or $code = 'R320' or $code = 'R4200'
                         or $code = 'R4201'
                         or $code = 'R121' or $code = 'R221'
                         or $code = 'R321' or $code = 'R4210'
                         or $code = 'R4211' or $code = 'R4220'
                         or $code = 'A1IB3491' or $code = 'A2IB3491'
                         or $code = 'A1914'
                         or $code = 'A1915'or $code = 'A2915'
                         or $code = 'A2624'
                         or $code = 'A1916'or $code = 'A2916'
                         or $code = 'A1603'or $code = 'A2603'
                         or $code = 'A1917'or $code = 'A2917'
                         or $code = 'A1918'or $code = 'A1919'">
                                    <xsl:value-of select="'【代理人】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-of-case-article">
                            <xsl:choose>
                                <xsl:when test="$code = 'A1711' or $code = 'A2711'">
                                    <xsl:value-of select="'【譲渡人代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A1712' or $code = 'A2712'">
                                    <xsl:value-of select="'【被承継人代理人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17432' or $code = 'A27432'
                         or $code = 'A17434' or $code = 'A27434'">
                                    <xsl:value-of select="'【代理人】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-change-article">
                            <xsl:choose>
                                <xsl:when
                                    test="$code = 'A163' or $code = 'A263'
                         or $code = 'A1632' or $code = 'A2632'
                         or $code = 'A1711' or $code = 'A2711'
                         or $code = 'A1712' or $code = 'A2712'
                         or $code = 'A17421' or $code = 'A27421'
                         or $code = 'A17423' or $code = 'A27423'">
                                    <xsl:value-of select="'【選任した代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17425' or $code = 'A27425'">
                                    <xsl:value-of select="'【解任した代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17426' or $code = 'A27426'">
                                    <xsl:value-of select="'【代理権を変更した代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17427' or $code = 'A27427'">
                                    <xsl:value-of select="'【代理権の消滅した代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17428' or $code = 'A27428'">
                                    <xsl:value-of select="'【援用を制限した代理人】'" />
                                </xsl:when>
                                <xsl:when
                                    test="$code = 'A17431' or $code = 'A27431'
                         or $code = 'A17433' or $code = 'A27433'">
                                    <xsl:value-of select="'【選任した復代理人】　'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17435' or $code = 'A27435'">
                                    <xsl:value-of select="'【解任した復代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17436' or $code = 'A27436'">
                                    <xsl:value-of select="'【代理権を変更した復代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17437' or $code = 'A27437'">
                                    <xsl:value-of select="'【代理権の消滅した復代理人】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="ancestor::jp:attorney-disappear-article">
                            <xsl:choose>
                                <xsl:when test="$code = 'A17421' or $code = 'A27421'">
                                    <xsl:value-of select="'【代理権の消滅した代理人】'" />
                                </xsl:when>
                                <xsl:when test="$code = 'A17431' or $code = 'A27431'">
                                    <xsl:value-of select="'【代理権の消滅した復代理人】'" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="書誌編集エラー処理" />
                                </xsl:otherwise>
                            </xsl:choose>
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
            <xsl:value-of select="$agentKind" />
        </xf:string>
        <xf:string key="indentLevel">
            <xsl:value-of select="$base-num-of-spaces + $num-of-spaces" />
        </xf:string>
    </xsl:template>

</xsl:stylesheet>