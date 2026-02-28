<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:jp="http://www.jpo.go.jp"
                xmlns:schema="urn:schema-dsl">

    <!-- this file is used for generating JSON schema for images information -->
    
    <schema:title>images-information</schema:title>
    <schema:object name="images-information" is-root="true">
        <!-- images-information.json は ocr の結果, 代表図の情報が追加される。
             text は ocr の項目, representative は代表図の項目。 -->
        <schema:property name="filename" type="string"/>
        <schema:property name="sha256" type="string"/>
        <schema:property name="media_type" type="string"/>
        <schema:property name="kind" type="string"/>
        <schema:property name="number" type="string" optional="true"/>
        <schema:property name="description" type="string" optional="true"/>
        <schema:property name="text" type="string" optional="true"/>
        <schema:property name="representative" type="boolean" optional="true"/>
        <schema:property name="derived" type="array">
            <schema:ref name="derived-image"/>
        </schema:property>
    </schema:object>
    <schema:object name="derived-image">
        <schema:property name="filename" type="string"/>
        <schema:property name="sha256" type="string"/>
        <schema:property name="media_type" type="string"/>
        <schema:property name="width" type="integer"/>
        <schema:property name="height" type="integer"/>
        <schema:property name="attributes" type="array" optional="true">
            <schema:ref name="image-attributes"/>
        </schema:property>
    </schema:object>
    <schema:object name="image-attributes">
        <schema:property name="key" type="string"/>
        <schema:property name="value" type="string"/>
    </schema:object>
</xsl:stylesheet>
