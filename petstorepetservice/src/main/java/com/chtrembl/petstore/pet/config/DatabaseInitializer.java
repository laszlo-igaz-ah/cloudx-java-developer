package com.chtrembl.petstore.pet.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StreamUtils;

import java.nio.charset.StandardCharsets;

@Component
@Slf4j
public class DatabaseInitializer implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    public DatabaseInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    @Transactional
    public void run(String... args) {
        log.info("Checking if database tables exist...");
        
        if (tablesExist()) {
            log.info("Database tables already exist. Skipping initialization.");
            return;
        }

        log.info("Database tables not found. Initializing database from petservice.sql...");
        
        try {
            ClassPathResource resource = new ClassPathResource("petservice.sql");
            String sqlScript = StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
            
            // Split the SQL script by semicolons and execute each statement
            String[] statements = sqlScript.split(";");
            
            for (String statement : statements) {
                String trimmedStatement = statement.trim();
                if (!trimmedStatement.isEmpty() && !trimmedStatement.startsWith("--")) {
                    try {
                        jdbcTemplate.execute(trimmedStatement);
                        log.debug("Executed SQL statement: {}", trimmedStatement.substring(0, Math.min(50, trimmedStatement.length())));
                    } catch (Exception e) {
                        log.warn("Error executing SQL statement: {}", e.getMessage());
                        // Continue with next statement
                    }
                }
            }
            
            log.info("Database initialization completed successfully.");
        } catch (Exception e) {
            log.error("Error initializing database: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to initialize database", e);
        }
    }

    private boolean tablesExist() {
        try {
            // Check if the 'pet' table exists (as a representative table)
            String sql = "SELECT COUNT(*) FROM information_schema.tables " +
                        "WHERE table_schema = 'public' AND table_name = 'pet'";
            
            Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
            return count != null && count > 0;
        } catch (Exception e) {
            log.debug("Error checking table existence: {}", e.getMessage());
            return false;
        }
    }
}

