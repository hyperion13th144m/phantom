<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:jp="http://www.jpo.go.jp"
    xmlns:schema="urn:schema-dsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xf="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xsl jp schema xf">

    <xsl:output method="text" encoding="UTF-8" />

    <!-- ======================
         begin root/jp:procedure
         ====================== -->
    <!-- 法律種別 -->
    <xsl:template match="jp:law">
        <xf:string key="law">
            <xsl:choose>
                <xsl:when test=". = '1'">patent</xsl:when>
                <xsl:when test=". = '2'">utilityModel</xsl:when>
                <xsl:when test=". = '3'">design</xsl:when>
                <xsl:when test=". = '4'">trademark</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xf:string>
    </xsl:template>

    <!-- 文書名 文書コード-->
    <xsl:template match="jp:document-name">
        <xf:string key="documentName">
            <xsl:value-of select="." />
        </xf:string>
        <xf:string key="documentCode">
            <xsl:value-of select="@jp:document-code" />
        </xf:string>
    </xsl:template>

    <!-- 出願番号 -->
    <xsl:template match="jp:application-number">
        <xf:string key="applicationNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>

    <!-- 登録番号 -->
    <xsl:template match="jp:registration-number">
        <xf:string key="registrationNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>

    <!-- 国際出願番号 -->
    <xsl:template match="jp:international-application-number">
        <xf:string key="internationalApplicationNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>

    <!-- 審判番号 -->
    <xsl:template match="jp:appeal-reference-number">
        <xf:string key="appealReferenceNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>

    <!-- 受領番号 -->
    <xsl:template match="jp:receipt-number">
        <xf:string key="receiptNumber">
            <xsl:value-of select="." />
        </xf:string>
    </xsl:template>

    <!-- 整理番号(出願系、発送系と共用) -->
    <xsl:template match="jp:file-reference-id |
        jp:procedure-infomation/jp:application-reference/jp:reference-id">
        <xsl:if test="normalize-space(.) != ''">
            <xf:string key="fileReferenceId">
                <xsl:value-of select="." />
            </xf:string>
        </xsl:if>
    </xsl:template>

    <!-- same key "datetime" is used for submission-date and dispatch-date.
         only one of them has jp:date and jp:time text content in one document.
         type is string, value is unix epoch time second
         to calculate a Unix epoch timestamp (seconds since 1970-01-01T00:00:00Z) in XSLT by:
          1. Parsing your date/time into an xs:dateTime value.
          2. Normalizing to UTC (accounting for the timezone).
          3. Subtracting the Unix epoch start date.
          4. Converting the resulting duration into total seconds. -->
    <xsl:template match="jp:submission-date | jp:dispatch-date">
        <xsl:if test="normalize-space(jp:date) != '' and normalize-space(jp:time) != ''">
            <xf:string key="datetime">
                <xsl:call-template name="normalizeDateTime">
                    <xsl:with-param name="date" select="jp:date" />
                    <xsl:with-param name="time" select="jp:time" />
                </xsl:call-template>
            </xf:string>
        </xsl:if>
    </xsl:template>
    <xsl:template name="normalizeDateTime">
        <xsl:param name="date" />
        <xsl:param name="time" />
        <xsl:if test="normalize-space($date) != '' and normalize-space($time) != ''">
            <xsl:variable name="year" select="substring($date, 1, 4)" />
            <xsl:variable name="month" select="substring($date, 5, 2)" />
            <xsl:variable name="day" select="substring($date, 7, 2)" />
            <xsl:variable name="hour" select="substring($time, 1, 2)" />
            <xsl:variable name="minute" select="substring($time, 3, 2)" />
            <xsl:variable name="second" select="substring($time, 5, 2)" />
            <!-- Assuming the time is in JST (UTC+9), we can create an xs:dateTime and then convert it to UTC -->
            <xsl:variable name="inputDateTime" as="xs:dateTime" select="xs:dateTime(concat($year, '-', $month, '-', $day, 'T', $hour, ':', $minute, ':', $second, '+09:00'))" />
            <xsl:variable name="utcDateTime" as="xs:dateTime" select="adjust-dateTime-to-timezone($inputDateTime, xs:dayTimeDuration('PT0H'))" />
            <xsl:variable name="epochStart" as="xs:dateTime" select="xs:dateTime('1970-01-01T00:00:00Z')" />
            <xsl:variable name="duration" select="$utcDateTime - $epochStart" />
            <xsl:variable name="totalSeconds" select="(days-from-duration($duration) * 86400)
                  + (hours-from-duration($duration) * 3600)
                  + (minutes-from-duration($duration) * 60)
                  + seconds-from-duration($duration)"/>
            <!-- datetime in milliseconds -->
            <xsl:value-of select="$totalSeconds || '000'" />
        </xsl:if>
    </xsl:template>
    <!-- ======================
         end root/jp:procedure
         ====================== -->

    <!-- ======================
         begin root/jp:pat-appd
         の inventors, applicants, agents 呼び出し
         ====================== -->
    <xsl:template match="jp:application-a63 | jp:application-a631 |
            jp:application-a632 | jp:application-a633 |
            jp:application-a634 | jp:application-a635">
        <xsl:apply-templates select="jp:inventors" />
        <xsl:apply-templates select="jp:applicants" />
        <!--jp:agents/jp:agent, jp:change-attorney-article/jp:agent
             をまとめるため、ここに記載 -->
        <xf:array key="agents">
            <xsl:for-each select=".//jp:agent">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    <!-- ======================
         end root/jp:pat-appd
         ====================== -->

    <!-- ======================
         begin root/jp:pat-amnd
         の applicants, agents 呼び出し
         ====================== -->
    <!-- 
         amendment-grooup 下の applicants，agents を処理しない。
         そのために、jp:amendment-a51 の直下の jp:applicants, jp:agents を処理対処にする
         補正書以外の書類でも同様に処理する
    -->
    <xsl:template match="jp:amendment-a51 | jp:amendment-a523 | jp:amendment-a524 |
            jp:amendment-a525 | jp:amendment-a529 |
            jp:amendment-a526 | jp:amendment-a5210 |
            jp:amendment-a527 | jp:amendment-a5211 |
            jp:amendment-a528 | jp:amendment-a5212">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
    </xsl:template>
    <!-- ======================
         end root/jp:pat-amnd
         ====================== -->

    <!-- ======================
         begin root/jp:pat-rspn
         の applicants, agents 呼び出し
         ====================== -->
    <xsl:template match="jp:response-a53 | jp:response-a59">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
    </xsl:template>
    <!-- ======================
         end root/jp:pat-rspn
         ====================== -->

    <!-- ======================
         begin root/jp:pat-etc
         の applicants, agents 呼び出し
         ====================== -->
    <xsl:template match="jp:etcetera-a601 | jp:etcetera-a621 | jp:etcetera-a623 |
            jp:etcetera-a624 | jp:etcetera-a625 | jp:etcetera-a626 | jp:etcetera-a627 |
            jp:etcetera-a67 | jp:etcetera-a691 | jp:etcetera-a781 | jp:etcetera-a821 |
            jp:etcetera-a831 | jp:etcetera-a87 | jp:etcetera-a871 | jp:etcetera-a872 |
            jp:etcetera-a914 | jp:etcetera-a915 | jp:etcetera-a916 | jp:etcetera-a603 |
            jp:etcetera-a917 | jp:etcetera-a918 | jp:etcetera-a919">
        <xsl:apply-templates select="jp:applicants" />
        <xsl:apply-templates select="jp:agents" />
    </xsl:template>
    <!-- ======================
         end root/jp:pat-etc
         ====================== -->

    <!-- ======================
         begin pat-appd, pat-amnd, pat-rspn, jp:pat-etc
         の inventors, applicants, agents 定義
         ====================== -->
    <!-- 出願人 -->
    <xsl:template match="jp:applicants">
        <xf:array key="applicants">
            <xsl:for-each select="jp:applicant">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>

    <!-- 発明者 -->
    <xsl:template match="jp:inventors">
        <xf:array key="inventors">
            <xsl:for-each select="jp:inventor">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>

    <!-- 代理人 -->
    <xsl:template match="jp:agents">
        <xf:array key="agents">
            <xsl:for-each select="jp:agent">
                <xf:string>
                    <xsl:value-of select=".//jp:name" />
                </xf:string>
            </xsl:for-each>
        </xf:array>
    </xsl:template>
    <!-- ======================
         end pat-appd, pat-amnd, pat-rspn, jp:pat-etc
         の inventors, applicants, agents 定義
         ====================== -->

    <!-- ======================
         begin 発送系の出願人、代理人, 整理番号
         ====================== -->
    <xsl:template match="jp:m-mi-notice-doc">
        <!-- 出願人 -->
        <xf:array key="applicants">
            <xsl:for-each select=".//jp:m-applicant-and-attorneys/jp:m-dispatch-applicant-group">
                <xsl:for-each select="jp:m-name">
                    <xf:string>
                        <xsl:value-of select="." />
                    </xf:string>
                </xsl:for-each>
            </xsl:for-each>
        </xf:array>

        <!-- 代理人 -->
        <xf:array key="agents">
            <xsl:for-each select=".//jp:m-applicant-and-attorneys/jp:m-dispatch-attorney-group">
                <xsl:for-each select="jp:m-name">
                    <xf:string>
                        <xsl:value-of select="." />
                    </xf:string>
                </xsl:for-each>
            </xsl:for-each>
        </xf:array>
    </xsl:template>

    <xsl:template match="jp:dispatch-control-article">
        <xsl:apply-templates select="jp:file-reference-id" />
    </xsl:template>

    <!-- ======================
         end 発送系の出願人、代理人
         ====================== -->

    <!-- docId など -->
    <xsl:template match="sources">
        <!-- sources/archive の sha256 を docId とする -->
        <xf:string key="docId">
            <xsl:value-of select="archive/@sha256" />
        </xf:string>
        <xf:string key="task">
            <xsl:value-of select="archive/@task" />
        </xf:string>
        <xf:string key="kind">
            <xsl:value-of select="archive/@kind" />
        </xf:string>
        <xf:string key="extension">
            <xsl:value-of select="archive/@extension" />
        </xf:string>
    </xsl:template>

    <xsl:template match="text()" />
</xsl:stylesheet>
