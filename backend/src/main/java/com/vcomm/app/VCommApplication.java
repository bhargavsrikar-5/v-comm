package com.vcomm.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class VCommApplication {

    public static void main(String[] args) {
        SpringApplication.run(VCommApplication.class, args);
        System.out.println("=================================================");
        System.out.println("🚀 V-COMM Spring Boot Backend Started Successfully!");
        System.out.println("   REST API Base URL: http://localhost:8080/api");
        System.out.println("=================================================");
    }
}
