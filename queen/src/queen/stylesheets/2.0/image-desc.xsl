<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl"
                xmlns:xf="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="xsl jp schema xf">
    
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:variable name="law-code" select="/root/jp:procedure//jp:law" />
    <xsl:variable name="kind-of-law">
        <xsl:choose>
            <xsl:when test="$law-code='1'">patent</xsl:when>
            <xsl:when test="$law-code='2'">utility</xsl:when>
            <xsl:when test="$law-code='3'">design</xsl:when>
            <xsl:when test="$law-code='4'">trademark</xsl:when>
            <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:param name="debug" select="'false'"/>
    
    <xsl:include href="common-templates/special-mention-matter-article.xsl" />
    <xsl:include href="common-templates/string-utils.xsl" />
    <xsl:include href="debug.xsl"/>
    
    <xsl:template match="/">
        <xsl:variable name="root">
            <xf:array>
                <xsl:apply-templates select="root/application-body/drawings" />
            </xf:array>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$debug = 'true'">
                <xsl:apply-templates select="$root/xf:map"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="xml-to-json($root)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="drawings">
        <xsl:for-each select="figure">
            <xsl:variable name="num" select="@num" />
            <xsl:variable name="file" select="img/@file" />
            <xsl:variable name="repr-image" select="//jp:representation-image/jp:file-name"/>
            <!-- 図面の簡単な説明 figref の num と、
                 図面のfigure の num は一致しないことがある。
                 外内などは図番号に "1-1"とか使われるが、
                 figrefは通番で1,2,3,... であるため。
                 1-1, 1-2 などは、図1扱いとして、figref num=1 の説明を description にする。
            -->     

            <xf:map>
                <xf:string key="number">
                    <xsl:value-of select="$num" />
                </xf:string>
                <xf:string key="file">
                    <xsl:value-of select="$file" />
                </xf:string>
                <xf:string key="description">
                    <xsl:variable name="normalize-fignum">
                        <xsl:choose>
                            <xsl:when test="contains($num, '-')">
                                <xsl:value-of select="substring-before($num, '-')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$num"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:for-each select="//description-of-drawings//figref">
                        <xsl:if test="./@num = $normalize-fignum">
                            <xsl:value-of select="normalize-space(.)" />
                        </xsl:if>
                    </xsl:for-each>
               </xf:string>
                <xf:boolean key="representative">
                    <xsl:choose>
                        <xsl:when test="$repr-image = $file">
                            <xsl:text>true</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>false</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xf:boolean>
            </xf:map>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>