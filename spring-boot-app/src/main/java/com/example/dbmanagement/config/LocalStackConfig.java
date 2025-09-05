package com.example.dbmanagement.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.rds.RdsClient;
import software.amazon.awssdk.services.sts.StsClient;

import java.net.URI;

@Configuration
@Profile("localstack")
public class LocalStackConfig {
    
    @Value("${aws.endpoint}")
    private String awsEndpoint;
    
    @Value("${aws.access-key}")
    private String awsAccessKey;
    
    @Value("${aws.secret-key}")
    private String awsSecretKey;
    
    @Value("${aws.region}")
    private String awsRegion;
    
    @Bean
    public AwsBasicCredentials awsCredentials() {
        return AwsBasicCredentials.create(awsAccessKey, awsSecretKey);
    }
    
    @Bean
    public StaticCredentialsProvider credentialsProvider() {
        return StaticCredentialsProvider.create(awsCredentials());
    }
    
    @Bean
    public RdsClient rdsClient() {
        return RdsClient.builder()
                .endpointOverride(URI.create(awsEndpoint))
                .credentialsProvider(credentialsProvider())
                .region(Region.of(awsRegion))
                .build();
    }
    
    @Bean
    public StsClient stsClient() {
        return StsClient.builder()
                .endpointOverride(URI.create(awsEndpoint))
                .credentialsProvider(credentialsProvider())
                .region(Region.of(awsRegion))
                .build();
    }
}
