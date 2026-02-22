<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jp="http://www.jpo.go.jp">

    <!-- this xslt was created with reference to pat_common.xsl
         of Internet Application Software version -->

    <!-- 出願番号等の変換関連のテンプレート-->

    <!-- 出願番号の変換
     長いのでこっちに移した -->
    <!-- ====================================================================
     文書番号内容編集
     ====================================================================-->
    <xsl:template
        name="文書番号内容編集">
        <xsl:variable name="number" select="normalize-space(.)" as="xs:string" />
        <xsl:variable name="law" select="ancestor::jp:application-reference/@jp:kind-of-law"
            as="xs:string" />
        <xsl:variable name="kinddoc" as="xs:string">
            <xsl:choose>
                <xsl:when test="ancestor::jp:contents-of-amendment">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::jp:contents-of-amendment//jp:contents-of-amendment">
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment//jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="ancestor::jp:contents-of-amendment/@jp:kind-of-document" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="number-as-int" select="xs:integer($number)" as="xs:integer" />
        <xsl:variable name="number-length" select="string-length($number)" as="xs:integer" />

        <!--  項目内容の編集  -->
        <xsl:choose>
            <!--　出願番号　-->
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'application']">
                <xsl:choose>
                    <xsl:when test="$number-length != 10">
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$number-as-int &gt;= 2000000000">
                                <xsl:choose>
                                    <xsl:when test="$law = 'patent'">
                                        <xsl:value-of select="'特願'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'utility'">
                                        <xsl:value-of select="'実願'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'design'">
                                        <xsl:value-of select="'意願'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'trademark'">
                                        <xsl:value-of select="'商願'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'　　'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!-- '.' に含まれる後半6桁については, オリジナル pat_common.xslでは先頭から続く0はスペースに変換していた。
                                    '2001000001' -> '2001-     1'
                                    ここでは  0 そのまま表示する。
                                    '2001000001' -> '2001-000001'
                                -->
                                <xsl:value-of
                                    select="substring($number,1,4) || '-' || substring($number, 5)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="和暦変換" />
                                <xsl:choose>
                                    <xsl:when test="$law = 'patent'">
                                        <xsl:value-of select="'特許願'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'utility'">
                                        <xsl:value-of select="'実用新案登録願'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'design'">
                                        <xsl:value-of select="'意匠登録願'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'trademark'">
                                        <xsl:choose>
                                            <xsl:when
                                                test="$kinddoc = 'jp:payment-r100' or $kinddoc = 'jp:payment-r110'">
                                                <xsl:value-of select="'商標登録願'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="$kinddoc = 'jp:payment-r103' or $kinddoc = 'jp:payment-r113'">
                                                <xsl:value-of select="'防護標章登録願'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="$kinddoc = 'jp:payment-r104' or $kinddoc = 'jp:payment-r114'">
                                                <xsl:value-of select="'商標更新登録願'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="$kinddoc = 'jp:payment-r105' or $kinddoc = 'jp:payment-r115'">
                                                <xsl:value-of select="'防護標章更新登録願'" />
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'　　'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="'第' || substring($number, 5) || '号'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>


            <!-- 国際出願番号
                  INPUT:
                    $number : 出願番号文字列 (10桁)
            -->
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'international-application']">
                <xsl:choose>
                    <xsl:when test="$number-length = 12">
                        <xsl:value-of
                            select="'PCT/' || substring($number,1,6) || '/' || substring($number,7,6)" />
                    </xsl:when>
                    <xsl:when test="$number-length = 9">
                        <xsl:value-of
                            select="'PCT/' || substring($number,1,4) || '/' || substring($number,5,5)" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- 登録番号
              INPUT:
                $number : 登録番号文字列
                $law : 法律の種類 (patent, utility, design, trademark)
            -->
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'registration']">
                <xsl:choose>
                    <xsl:when
                        test="($law = 'patent' and $number-length != 7)
                     or ($law = 'utility' and $number-length != 7)">
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:when>
                    <xsl:when
                        test="($law != 'patent' and $law != 'utility')
                    and ($number-length &lt; 7)">
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:when>
                    <xsl:when
                        test="(($law != 'patent' and $law != 'utility') and ($number-length &gt; 8))
                      and not((substring($number,8,1) = '/') or (substring($number,8,1) = '-')) ">
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$law = 'patent'">
                                <xsl:value-of select="'特許第'" />
                            </xsl:when>
                            <xsl:when test="$law = 'utility'">
                                <xsl:value-of select="'実用新案登録第'" />
                            </xsl:when>
                            <xsl:when test="$law = 'design'">
                                <xsl:value-of select="'意匠登録第'" />
                            </xsl:when>
                            <xsl:when test="$law = 'trademark'">
                                <xsl:value-of select="'商標登録第'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'　　第'" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="substring($number, 1, 7) || '号'" />
                        <xsl:if test="$number-length &gt;= 8">
                            <xsl:choose>
                                <xsl:when test="substring($number,8,1) = '/'">
                                    <xsl:call-template name="類似番号編集">
                                        <xsl:with-param name="no" select="substring($number,8)" />
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="substring($number,8,1) = '-'">
                                    <xsl:call-template name="分割番号編集">
                                        <xsl:with-param name="no" select="substring($number,8)" />
                                        <xsl:with-param name="keta"
                                            select="string-length(substring($number,8))" />
                                    </xsl:call-template>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- 公告番号
                INPUT:
                    $number : 公告番号文字列 (10桁)
                    $law : 法律の種類 (patent, utility, trademark)
            -->
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'examined-pub']">
                <xsl:choose>
                    <xsl:when test="$number-length != 10">
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="和暦変換" />
                        <xsl:choose>
                            <xsl:when test="$law = 'patent'">
                                <xsl:value-of select="'特許'" />
                            </xsl:when>
                            <xsl:when test="$law = 'utility'">
                                <xsl:value-of select="'実用新案'" />
                            </xsl:when>
                            <xsl:when test="$law = 'trademark'">
                                <xsl:value-of select="'商標'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'Unknown doc-number'" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="'出願公告第' || substring($number, 5, 6) || '号'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- 公開番号の変換
                INPUT:
                    $number : 公開番号文字列 (10桁)
                    $law : 法律の種類 (patent, utility)
            -->
            <xsl:when
                test="ancestor::jp:application-reference
                and ancestor::jp:application-reference [@appl-type = 'un-examined-pub']">
                <xsl:choose>
                    <xsl:when test="$number-length != 10">
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$number-as-int &gt;= 2000000000">
                                <xsl:choose>
                                    <xsl:when test="$law = 'patent'">
                                        <xsl:value-of select="'特開'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'utility'">
                                        <xsl:value-of select="'実開'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown doc-number'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of
                                    select="substring($number,1,4) || '-' || substring($number, 5, 6)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="和暦変換" />
                                <xsl:choose>
                                    <xsl:when test="$law = 'patent'">
                                        <xsl:value-of select="'特許'" />
                                    </xsl:when>
                                    <xsl:when test="$law = 'utility'">
                                        <xsl:value-of select="'実用新案'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Unknown doc-number'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="'出願公開第' || substring($number, 5, 6) || '号'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>


            <!-- 審判番号の変換
                INPUT:
                    $number : 審判番号文字列 (9桁または10桁)
            -->
            <xsl:when test="ancestor::jp:appeal-reference">
                <xsl:choose>
                    <xsl:when test="string-length($number) = 9">
                        <xsl:variable name="last-5digits"
                            select="xs:integer(substring($number,5,5))" as="xs:integer" />
                        <xsl:choose>
                            <xsl:when test="$number-as-int &gt;= 200700000">
                                <xsl:value-of select="'Unknown doc-number'" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="$number-as-int &gt;= 200000000">
                                        <xsl:choose>
                                            <xsl:when
                                                test="1 &lt;= $last-5digits and $last-5digits &lt;= 30000">
                                                <xsl:value-of select="'不服'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="30001 &lt;= $last-5digits and $last-5digits  &lt;= 35000">
                                                <xsl:value-of select="'取消'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="35001 &lt;= $last-5digits and $last-5digits  &lt;= 39000">
                                                <xsl:value-of select="'無効'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="39001 &lt;= $last-5digits and $last-5digits  &lt;= 40000">
                                                <xsl:value-of select="'訂正'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="40001 &lt;= $last-5digits and $last-5digits  &lt;= 50000">
                                                <xsl:value-of select="'無効'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="50001 &lt;= $last-5digits and $last-5digits  &lt;= 60000">
                                                <xsl:value-of select="'補正'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="60001 &lt;= $last-5digits and $last-5digits  &lt;= 65000">
                                                <xsl:value-of select="'判定'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="65001 &lt;= $last-5digits and $last-5digits  &lt;= 66000">
                                                <xsl:value-of select="'不服'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="66001 &lt;= $last-5digits and $last-5digits  &lt;= 67000">
                                                <xsl:value-of select="'取消'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="67001 &lt;= $last-5digits and $last-5digits  &lt;= 68000">
                                                <xsl:value-of select="'無効'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="68001 &lt;= $last-5digits and $last-5digits  &lt;= 69000">
                                                <xsl:value-of select="'異議'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="69001 &lt;= $last-5digits and $last-5digits  &lt;= 69500">
                                                <xsl:value-of select="'補正'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="69501 &lt;= $last-5digits and $last-5digits  &lt;= 69600">
                                                <xsl:value-of select="'判定'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="69601 &lt;= $last-5digits and $last-5digits  &lt;= 69700">
                                                <xsl:value-of select="'再審'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="69701 &lt;= $last-5digits and $last-5digits  &lt;= 69800">
                                                <xsl:value-of select="'除斥'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="69801 &lt;= $last-5digits and $last-5digits  &lt;= 69900">
                                                <xsl:value-of select="'忌避'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="69901 &lt;= $last-5digits and $last-5digits  &lt;= 70000">
                                                <xsl:value-of select="'証拠'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="70001 &lt;= $last-5digits and $last-5digits  &lt;= 95000">
                                                <xsl:choose>
                                                    <xsl:when
                                                        test="$number-as-int &gt;= 200400000 and 80001 &lt;= $last-5digits and $last-5digits  &lt;= 90000">
                                                        <xsl:value-of select="'無効'" />
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'異議'" />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:when
                                                test="95001 &lt;= $last-5digits and $last-5digits  &lt;= 96000">
                                                <xsl:value-of select="'再審'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="96001 &lt;= $last-5digits and $last-5digits  &lt;= 97000">
                                                <xsl:value-of select="'除斥'" />
                                            </xsl:when>
                                            <xsl:when
                                                test="97001 &lt;= $last-5digits and $last-5digits  &lt;= 98000">
                                                <xsl:value-of select="'忌避'" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'証拠'" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:value-of
                                            select="substring($number,1,4) || '-'" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="和暦変換" />
                                        <xsl:value-of select="'審判第'" />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="substring($number, 5, 5)" />
                                <xsl:if test="$number-as-int &lt; 200000000">
                                    <xsl:value-of select="'号'" />
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:when test="$number-length = 10">
                        <xsl:choose>
                            <xsl:when test="$number-as-int &gt;= 2007000001">
                                <xsl:variable name="last-6digits"
                                    select="xs:integer(substring($number,5,6))" as="xs:integer" />
                                <xsl:choose>
                                    <xsl:when
                                        test="1 &lt;= number(substring($number,5,6)) and number(substring($number,5,6)) &lt;= 199999">
                                        <xsl:value-of select="'不服'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="300001 &lt;= $last-6digits and $last-6digits  &lt;= 349999">
                                        <xsl:value-of select="'取消'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="390001 &lt;= $last-6digits and $last-6digits  &lt;= 399999">
                                        <xsl:value-of select="'訂正'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="400001 &lt;= $last-6digits and $last-6digits  &lt;= 409999">
                                        <xsl:value-of select="'無効'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="500001 &lt;= $last-6digits and $last-6digits  &lt;= 509999">
                                        <xsl:value-of select="'補正'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="600001 &lt;= $last-6digits and $last-6digits  &lt;= 609999">
                                        <xsl:value-of select="'判定'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="650001 &lt;= $last-6digits and $last-6digits  &lt;= 669999">
                                        <xsl:value-of select="'不服'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="670001 &lt;= $last-6digits and $last-6digits  &lt;= 679999">
                                        <xsl:value-of select="'取消'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="680001 &lt;= $last-6digits and $last-6digits  &lt;= 684999">
                                        <xsl:value-of select="'無効'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="685001 &lt;= $last-6digits and $last-6digits  &lt;= 689999">
                                        <xsl:value-of select="'異議'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="690001 &lt;= $last-6digits and $last-6digits  &lt;= 694999">
                                        <xsl:value-of select="'補正'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="695001 &lt;= $last-6digits and $last-6digits  &lt;= 695999">
                                        <xsl:value-of select="'判定'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="696001 &lt;= $last-6digits and $last-6digits  &lt;= 696999">
                                        <xsl:value-of select="'再審'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="697001 &lt;= $last-6digits and $last-6digits  &lt;= 697999">
                                        <xsl:value-of select="'除斥'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="698001 &lt;= $last-6digits and $last-6digits  &lt;= 698999">
                                        <xsl:value-of select="'忌避'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="699001 &lt;= $last-6digits and $last-6digits  &lt;= 699999">
                                        <xsl:value-of select="'証拠'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="700001 &lt;= $last-6digits and $last-6digits  &lt;= 799999">
                                        <xsl:value-of select="'異議'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="800001 &lt;= $last-6digits and $last-6digits  &lt;= 899999">
                                        <xsl:value-of select="'無効'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="900001 &lt;= $last-6digits and $last-6digits  &lt;= 909999">
                                        <xsl:value-of select="'異議'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="950001 &lt;= $last-6digits and $last-6digits  &lt;= 959999">
                                        <xsl:value-of select="'再審'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="960001 &lt;= $last-6digits and $last-6digits  &lt;= 969999">
                                        <xsl:value-of select="'除斥'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="970001 &lt;= $last-6digits and $last-6digits  &lt;= 979999">
                                        <xsl:value-of select="'忌避'" />
                                    </xsl:when>
                                    <xsl:when
                                        test="980001 &lt;= $last-6digits and $last-6digits  &lt;= 989999">
                                        <xsl:value-of select="'証拠'" />
                                    </xsl:when>
                                </xsl:choose>
                                <xsl:value-of
                                    select="substring($number,1,4) || '-' || substring($number, 5, 6)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'Unknown doc-number'" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'Unknown doc-number'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- その他 -->
            <xsl:otherwise>
                <xsl:value-of select="$number" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
     類似番号編集
     ====================================================================-->
    <xsl:template
        name="類似番号編集">
        <xsl:param name="no" />
        <xsl:value-of select="'の第　'" />
        <xsl:value-of select="substring($no,2)" />
        <xsl:value-of select="'　号'" />
    </xsl:template>

    <!-- ====================================================================
     分割番号編集
     ====================================================================-->
    <xsl:template name="分割番号編集">
        <xsl:param name="no" />
        <xsl:param name="keta" />

        <xsl:if test="$keta &gt; 0">
            <xsl:choose>
                <xsl:when test="substring($no,1,1) = '-'">
                    <xsl:value-of select="'の'" />
                    <xsl:call-template name="分割番号編集">
                        <xsl:with-param name="no" select="substring($no,2)" />
                        <xsl:with-param name="keta" select="$keta - 1" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="substring($no,1,1) = '/'">
                    <xsl:call-template name="類似番号編集">
                        <xsl:with-param name="no" select="$no" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring($no,1,1)" />
                    <xsl:call-template name="分割番号編集">
                        <xsl:with-param name="no" select="substring($no,2)" />
                        <xsl:with-param name="keta" select="$keta - 1" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- ====================================================================
         和暦変換
         application-reference//jp:doc-number のコンテキストで呼び出す。
         出願番号基準で和暦変換を行う。
         INPUT: jp:doc-number e.g. 2000123456
         OUTPUT: 昭和|平成NN年
         ====================================================================-->
    <xsl:template name="和暦変換">
        <xsl:variable name="day" select="normalize-space(.)" />
        <xsl:variable name="year" as="xs:integer" select="xs:integer(substring($day, 1, 4))" />
        <xsl:variable name="doc-number" as="xs:integer" select="xs:integer(substring($day, 1, 10))" />
        <xsl:choose>
            <!--　四法が対象外　-->
            <xsl:when
                test="(ancestor::jp:application-reference [@jp:kind-of-law != 'patent']
                        and ancestor::jp:application-reference [@jp:kind-of-law != 'utility']
                        and ancestor::jp:application-reference [@jp:kind-of-law != 'design']
                        and ancestor::jp:application-reference [@jp:kind-of-law != 'trademark']) or
                    not(ancestor::jp:application-reference [@jp:kind-of-law]) ">
                <xsl:choose>
                    <xsl:when test="$year &gt;= 1989">
                        <xsl:call-template name="平成編集" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="昭和編集" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!--　出願番号　-->
            <xsl:when
                test="ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'application']">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-reference [@jp:kind-of-law = 'patent']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989001146">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'utility']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989000491">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="ancestor::jp:application-reference [@jp:kind-of-law = 'design']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989000124">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'trademark']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989000354">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!--　公告番号　-->
            <xsl:when
                test="ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'examined-pub']">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-reference [@jp:kind-of-law = 'patent']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989000600">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'utility']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989000480">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'trademark']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989000000">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!--　公開番号　-->
            <xsl:when
                test="ancestor::jp:application-reference
                    and ancestor::jp:application-reference [@appl-type = 'un-examined-pub']">
                <xsl:choose>
                    <xsl:when test="ancestor::jp:application-reference [@jp:kind-of-law = 'patent']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989003200">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when
                        test="ancestor::jp:application-reference [@jp:kind-of-law = 'utility']">
                        <xsl:choose>
                            <xsl:when test="$doc-number &gt; 1989001800">
                                <xsl:call-template name="平成編集" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="昭和編集" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!--　審判番号　-->
            <xsl:when test="ancestor::jp:appeal-reference">
                <xsl:choose>
                    <xsl:when test="$doc-number&gt; 198900000">
                        <xsl:call-template name="平成編集" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="昭和編集" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- ====================================================================
         平成編集
         INPUT: xs:string contains [0-9]+ in jp:doc-number
         OUTPUT: 平成NN年 
         ====================================================================-->
    <xsl:template name="平成編集">
        <xsl:variable name="year" as="xs:integer"
            select="xs:integer(substring(normalize-space(.),1,4))" />
        <xsl:variable name="hyy" select="$year - 1988" />
        <xsl:value-of select="'平成' || $hyy || '年'" />
    </xsl:template>

    <!-- ====================================================================
         昭和編集
         INPUT: xs:string contains [0-9]+ in jp:doc-number
         OUTPUT: 昭和NN年 
         ====================================================================-->
    <xsl:template name="昭和編集">
        <xsl:variable name="year" as="xs:integer"
            select="xs:integer(substring(normalize-space(.),1,4))" />
        <xsl:variable name="syy" select="$year - 1925" />
        <xsl:value-of select="'昭和' || $syy || '年'" />
    </xsl:template>
</xsl:stylesheet>