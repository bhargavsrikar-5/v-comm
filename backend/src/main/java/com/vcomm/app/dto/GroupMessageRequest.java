package com.vcomm.app.dto;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
public class GroupMessageRequest { @NotBlank @Size(max=4000) private String content; public String getContent(){return content;} public void setContent(String content){this.content=content==null?null:content.trim();} }
