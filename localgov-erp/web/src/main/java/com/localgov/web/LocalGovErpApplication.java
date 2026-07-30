package com.localgov.web;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.localgov")
@EntityScan(basePackages = "com.localgov.domain.model")
@EnableJpaRepositories(basePackages = "com.localgov.repository")
@EnableCaching
public class LocalGovErpApplication {
    public static void main(String[] args) {
        SpringApplication.run(LocalGovErpApplication.class, args);
    }

    @Bean
    CacheManager cacheManager() {
        return new ConcurrentMapCacheManager("schemaSnapshots");
    }
}
